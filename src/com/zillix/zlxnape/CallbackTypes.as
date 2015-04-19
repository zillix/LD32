package com.zillix.zlxnape
{
	import nape.callbacks.CbType;
	
	/**
	 * List of callback types, used for distinguishing collisions.
	 * @author zillix
	 */
	public class CallbackTypes 
	{
		public static var PLAYER:CbType = new CbType();
		public static var GROUND:CbType = new CbType();
		public static var ABSORB:CbType = new CbType();
		public static var PICKUP:CbType = new CbType();
		public static var ENEMY:CbType = new CbType();
		public static var BUBBLE:CbType = new CbType();
		public static var AIR:CbType = new CbType();
		public static var SHRINE:CbType = new CbType();
	}
	
}