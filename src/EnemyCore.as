package 
{
	import com.zillix.zlxnape.*;
	import com.zillix.zlxnape.ZlxNapeSprite;
	import com.zillix.utils.ZMathUtils;
	import nape.phys.Material;
	import org.flixel.FlxGroup;
	import nape.constraint.DistanceJoint;
	import nape.geom.*;
	import org.flixel.FlxPoint;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class EnemyCore extends CircleNapeSprite 
	{
		
		
		private var _nodeCount:int = 4;
		private var _nodeRadius:int = 10;
		
		private var _coreRadius:int = 7;
		
		
		private var _nodeDistance:int = 15;
		
		protected var _nodes:Vector.<EnemyNode> = new Vector.<EnemyNode>();
		private var _nodeLayer:FlxGroup;
		private var _joints:Vector.<DistanceJoint>;
		
		public static const JOINT_BREAK_FORCE:Number = 120;
		public static const JOINT_BREAK_FORCE_WEAK:Number = 80;
		public static const JOINT_BREAK_DIST:Number = 40;
		
		private var _nodesRemoved:Boolean = false;
		
		private var _breakable:Boolean = true;
		
		private var _spawnPoint:Vec2;
		
		private var _leashStartDist:int = 20;
		private var _leashEndDist:int = 5;
		private var _leashing:Boolean = false;
		private var _impulseAccel:Number = 5;
		
		private var _glow:Glow;
		
		
		public function EnemyCore(X:Number, Y:Number, Context:BodyContext, NodeLayer:FlxGroup, NodeCount:int)
		{
			super(X, Y, Context, _coreRadius);
			
			_nodeCount = NodeCount;
			
			_spawnPoint = Vec2.get(X, Y);
			
			setMaterial(new Material(0, 0, 0, Water.DENSITY + .5));
			
			_nodeLayer = NodeLayer;
			_joints = new Vector.<DistanceJoint>();
			
			addCbType(CallbackTypes.ENEMY);
			
			for (var i:int = 0; i < _nodeCount; i++)
			{
				var angle:Number = 360 / _nodeCount * i;
				var offsetX:Number = Math.cos(ZMathUtils.toRadians(angle)) * _nodeDistance;
				var offsetY:Number = Math.sin(ZMathUtils.toRadians(angle)) * _nodeDistance;
				var node:EnemyNode = new EnemyNode(x + offsetX, y + offsetY, Context, _nodeRadius); 
				_nodes.push(node);
				//node.fluidMask = 0;
				_nodeLayer.add(node);
				
				collisionGroup = InteractionGroups.ENEMY;
				collisionMask = ~(InteractionGroups.NO_COLLIDE | InteractionGroups.ENEMY_NODE | InteractionGroups.BUBBLE);
				
				var distanceJoint:DistanceJoint = new DistanceJoint(body, node.body,
					Vec2.get(),
					ZMathUtils.getVector(angle, _nodeDistance),
					0,
					5);
					
				distanceJoint.space = Context.space;
				
				if (_breakable)
				{
					distanceJoint.breakUnderForce = true;
					distanceJoint.breakUnderError = true;
					distanceJoint.maxError = JOINT_BREAK_DIST;
					distanceJoint.maxForce = JOINT_BREAK_FORCE;
					distanceJoint.removeOnBreak = true;
				}
				_joints.push(distanceJoint);
			}
			
			_glow = PlayState.instance.attachGlow(this, 50);
		}
		
		override public function update() : void
		{
			super.update();
			
			var i:int;
			for (i = 0; i < _joints.length; i++)
			{
				var joint:DistanceJoint = _joints[i];
				if (joint.space == null && _nodes[i])
				{
					killNode(i);
				}
			}
			
			
			
			var nodeCount:int = 0;
			for (i = 0; i < _nodes.length; i++)
			{
				if (_nodes[i] != null)
				{
					nodeCount++;
				}
			}
			
			if (nodeCount == 0)
			{
				onNodesRemoved();
			}
			
			if (nodeCount == 1)
			{
				weakenJoints();
			}
			
			var leashDist:Number = body.position.sub(_spawnPoint).length;
			if (leashDist > _leashStartDist)
			{
				_leashing = true;
			}
			
			if (_leashing && leashDist < _leashEndDist)
			{
				_leashing = false;
			}
			
			if (_leashing)
			{
				var impulse:Vec2 = _spawnPoint.sub(body.position).normalise().mul(_impulseAccel);
				body.applyImpulse(impulse);
				for each (var node:EnemyNode in _nodes)
				{
					if (node != null)
					{
						node.body.applyImpulse(impulse);
					}
				}
			}
		}
		
		protected function weakenJoints() : void
		{
			for each (var joint:DistanceJoint in _joints)
			{
				if (joint != null)
				{
					joint.maxForce = JOINT_BREAK_FORCE_WEAK;
				}
			}
		}
		
		protected function killNode(index:int) : void
		{
			if (_nodes[index] != null)
			{
				_nodes[index].kill();
				_nodes[index] = null;
			}
		}
		
		
		
		protected function onNodesRemoved() : void
		{
			if (_nodesRemoved)
			{
				return;
			}
			
			_nodesRemoved = true;
		
			kill();
			ejectPearl();
		}
		
		protected function ejectPearl() : void
		{
			var pearl:EnemyPearl = new EnemyPearl(x, y, PlayState.instance.bodyContext, radius, PlayState.instance.getTube());
			_glow.target = pearl;
			_nodeLayer.add(pearl);
		}
	}
	
}