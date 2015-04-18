package com.zillix.zlxnape.interfaces 
{
	import com.zillix.zlxnape.ZlxNapeSprite;
	
	/**
	 * ...
	 * @author zillix
	 */
	public interface IBoxSpawner 
	{
		function spawnBox(x:Number, y:Number, width:int = 20, angle:Number = 0, color:uint = 0) : ZlxNapeSprite;
	}
	
}