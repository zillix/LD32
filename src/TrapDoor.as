package 
{
	import com.zillix.zlxnape.BodyContext;
	import com.zillix.zlxnape.ColorSprite;
	import com.zillix.zlxnape.*;
	import nape.constraint.PivotJoint;
	import nape.phys.Material;
	import org.flixel.FlxGroup;
	import nape.phys.BodyType;
	import nape.geom.Vec2;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class TrapDoor extends ColorSprite 
	{
		public static const TRAP_DOOR_COLOR:uint = 0xff6D2901;
		private static const WIDTH:Number = 80;
		private static const HEIGHT:Number = 20;
		
		private var anchor:ZlxNapeSprite;
		private var joint:PivotJoint
		
		public function TrapDoor(X:Number, Y:Number, Context:BodyContext, AnchorLayer:FlxGroup)
		{
			super(X, Y, TRAP_DOOR_COLOR)
			createBody(WIDTH, HEIGHT, Context);
			
			setMaterial(new Material(0, 0, 0, Water.DENSITY + .1));
			
			anchor = new ZlxNapeSprite(X, Y);
			anchor.createBody(2, 2, Context, BodyType.KINEMATIC);
			anchor.collisionGroup = InteractionGroups.NO_COLLIDE;
			
			joint = new PivotJoint(anchor.body, this.body, Vec2.get(), getEdgeVector(DIRECTION_BACKWARDS));
			joint.space = Context.space;
			
			
		}
		
		override public function kill() : void
		{
			anchor.kill();
			super.kill();
		}
		
	}
	
}