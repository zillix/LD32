package com.zillix.zlxnape 
{
	import flash.display.BitmapData;
	import nape.constraint.DistanceJoint;
	import nape.constraint.PivotJoint;
	import nape.geom.Vec2;
	import nape.phys.*;
	import nape.space.Space;
	import org.flixel.*;
	import test.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class AttractionGroup
	{
		protected var _anchorPoint:FlxPoint;
		public var anchor:Absorbable;
		protected var _assimilated:Vector.<Absorbable>;
		protected var _timeLeft:Number;
		function AttractionGroup(pos:Vec2, s:Space, available:Vector.<Absorbable>, size:int, time:Number) : void
		{
			_timeLeft = time;
			_anchorPoint = new FlxPoint(pos.x, pos.y);
			anchor = new Absorbable(pos.x, pos.y);
			anchor.createBody(PlayState.PIXEL_WIDTH, PlayState.PIXEL_WIDTH, s, BodyType.KINEMATIC);
			available.push(anchor);
			
			_assimilated = new Vector.<Absorbable>();
			
			
			if (PlayState.instance.DEBUG)
			{
				anchor.makeGraphic(20, 20, 0xffffff00);
				PlayState.instance.foregroundObjects.add(anchor);
			}
			
			for (var i:int = 0; i < size; i++)
			{
				var obj:Absorbable = available.pop();
				if (obj != null)
				{
					obj.isBeingAssimilated = true;
					obj.collisionGroup = InteractionGroups.ATTRACTED_BOX;
					obj.collisionMask = InteractionGroups.ATTRACTED_BOX;
					_assimilated.push(obj);
				
				}
			}
			
		}
		
		public function update() : void
		{
			_timeLeft -= FlxG.elapsed;
			
			if (_timeLeft == 0)
			{
				
			}
			var dist:Number;
			var distVec:Vec2;
			var maxAttract:Number = 7;
			var maxAttractDist:Number = 200;
			var attraction:Number;
			for each (var box:Absorbable in _assimilated)
			{
				distVec = anchor.body.position.sub(box.body.position, true);
				dist = distVec.length;
				
				box.body.setVelocityFromTarget(anchor.body.position, box.body.rotation, _timeLeft);
			}
		}
		
	}

}