package com.zillix.zlxnape
{
	import flash.display.BitmapData;
	import nape.constraint.DistanceJoint;
	import nape.constraint.PivotJoint;
	import nape.geom.Vec2;
	import nape.space.Space;
	import nape.util.Debug;
	import org.flixel.*;
	
	import com.zillix.zlxnape.ZlxNapeSprite;
	
	/**
	 * Structure that tracks some quantity of joined sprites.
	 * Reads pixels from an input image and spawns a corresponding number of bodies,
	 * and then joins them in the same shape.
	 * @author zillix
	 */
	public class ConnectedPixelGroup 
	{
		
		private var _pixelMap:Vector.<Vector.<ZlxNapeSprite>>;
		private var _occupiedPoints:Vector.<FlxPoint>;
		private var _availableSprites:Vector.<ZlxNapeSprite>;
		private var _usedSprites:Vector.<ZlxNapeSprite>;
		private var _joints:Vector.<DistanceJoint>;
		private var _pivotJoints:Vector.<PivotJoint>;
		private var _space:Space;
		private var _maxDist:int = 1000;
		private var _minDist:int = 4;
		private var _cemented:Boolean = false;
		
		function ConnectedPixelGroup(s:Space, available:Vector.<ZlxNapeSprite>) : void
		{
			_space = s;
			_occupiedPoints = new Vector.<FlxPoint>();
			_availableSprites = available;
			_availableSprites.reverse();
			_usedSprites = new Vector.<ZlxNapeSprite>();
			_joints = new Vector.<DistanceJoint>();
			_pivotJoints = new Vector.<PivotJoint>();
		}
		
		public function loadImage(ImageClass:Class) : void
		{
			var bitmapData:BitmapData = (new ImageClass).bitmapData;
			if (bitmapData != null)
			{
				var column:uint;
				var pixel:uint;
				var bitmapWidth:uint = bitmapData.width;
				var bitmapHeight:uint = bitmapData.height;
				
				_pixelMap = new Vector.<Vector.<ZlxNapeSprite>>(bitmapData.width);
				for (var i:int = 0; i < bitmapWidth; i++)
				{
					_pixelMap[i] = new Vector.<ZlxNapeSprite>(bitmapHeight);
				}
			
				var endIndex:int = bitmapHeight - 1;
				var row:uint = 0;
				
				while(row < endIndex)
				{
					column = 0;
					while(column < bitmapWidth)
					{
						//Decide if this pixel/tile is solid (1) or not (0)
						pixel = bitmapData.getPixel32(column, row);
				
						processPixel(pixel, row, column, bitmapWidth, bitmapHeight);
						
						column++;
					}
					if (row == endIndex)
					{
						break;
					}
					else
					{
						row++;
					}
				
				}
				
				finishProcessing();
			}
		}
		
		private static const EMPTY:uint = 0xffffffff;
		private static const CLEAR:uint = 0x00000000;
		private static const BLACK:uint = 0xff000000;
		
		private function processPixel(color:uint, column:uint, row:uint, width:uint, height:uint) : void
		{
			if (color == EMPTY || color == CLEAR)
			{
				return;
			}
			
			_occupiedPoints.push(new FlxPoint(column, row));
			_pixelMap[column][row] = _availableSprites.pop();
			_usedSprites.push(_pixelMap[column][row]);
		}
		
		private function finishProcessing() : void
		{
			for each (var point:FlxPoint in _occupiedPoints)
			{
				if (point.x < _pixelMap.length - 1)
				{
					// Only join to the right or down
					// This guarantees we won't double-bind anything, but everything will still get linked
					
					if (_pixelMap[point.x + 1][point.y] != null)
					{
						join(_pixelMap[point.x][point.y], _pixelMap[point.x + 1][point.y], ZlxNapeSprite.DIRECTION_FORWARD);
					}
					if (_pixelMap[point.x][point.y + 1] != null)
					{
						join(_pixelMap[point.x][point.y], _pixelMap[point.x][point.y + 1], ZlxNapeSprite.DIRECTION_RIGHT);
					}
				}
			}
		}
		
		private function join(sprite1:ZlxNapeSprite, sprite2:ZlxNapeSprite, direction:int, numConnections:int = 1) : void
		{
			for (var i:int = 0; i < numConnections; i++)
			{
				// Establish links at regular intervals between the two sprites.
				// Offset the edge by the perpendicular of the vector between them, so you start in the corner.
				// Find the negative offset, which is -2x the offset
				// Figure out what fraction of the negative offset to add.
				// EX:
				//
				//		offset
				//		<-----
				//		negoffset
				//		------------->
				// 		body:
				//		------^------
				//		|	  | 	|
				//
				//
				//		two connections:
				//
				//		   1     2
				//		--->----->
				//		-------------
				//
				var edge:Vec2 = sprite1.getEdgeVector(direction);
				var offset:Vec2 = sprite1.getEdgeVector(direction).perp();
				var negOffset:Vec2 = offset.copy();
				negOffset.muleq( -2);
				var mult:Number = (i + 1) / (numConnections + 1);
				var negMult:Vec2 = negOffset.mul(mult);
				offset.addeq(negMult);
				
				var joint:DistanceJoint = new DistanceJoint(sprite1.body, sprite2.body, 
					sprite1.getEdgeVector(direction).add(offset),
					sprite2.getEdgeVector(ZlxNapeSprite.getOppositeDirection(direction)).add(offset), 
					0,
					Math.min(_maxDist,
						FlxU.getDistance(new FlxPoint(sprite1.x, sprite1.y), new FlxPoint(sprite2.x, sprite2.y))));
				joint.space = _space;
				joint.ignore = true;
				joint.debugDraw = true;
				_joints.push(joint);
			}
				
		}
		
		public function contract(amt:Number) : void
		{
			var longestJoint:int = 0;
			for each (var joint:DistanceJoint in _joints)
			{
				joint.jointMax = Math.max(_minDist, joint.jointMax - amt);
				longestJoint = Math.max(longestJoint, joint.jointMax);
			}
			
			if (!_cemented && longestJoint < 5)
			{
				cement();
			}
		}
		
		public function get usedSprites() : Vector.<ZlxNapeSprite>
		{
			return _usedSprites;
		}
		
		public function debugDraw(debug:Debug) : void
		{
			for each (var joint:DistanceJoint in _joints)
			{
				debug.draw(joint);
			}
			
			for each (var pJoint:PivotJoint in _pivotJoints)
			{
				debug.draw(pJoint);
			}
		}
		
		private function cement() : void
		{
			if (_cemented)
			{
				return;
			}
			
			_cemented = true;
			var pivotJoint:PivotJoint;
			for each (var joint:DistanceJoint in _joints)
			{
				pivotJoint = new PivotJoint(joint.body1, joint.body2, joint.anchor1, joint.anchor2);
				pivotJoint.space = _space;
				pivotJoint.ignore = true;
				joint.space = null;
			}
			
			_pivotJoints.length = 0;
		}
	}
	
}