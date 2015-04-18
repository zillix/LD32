package com.zillix.zlxnape
{
	import flash.utils.Dictionary;
	import nape.phys.Body;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class BodyMap 
	{
		private var _bodiesByColor:Dictionary;
		private var _bodyList:Vector.<Body>;
		
		private var _shapeColors:Vector.<uint>;
		
		function BodyMap()
		{
			_bodiesByColor = new Dictionary();
			_bodyList = new Vector.<Body>();
		}
		
		public function addBody(body:Body, color:uint) : void
		{
			if (color in _bodiesByColor)
			{
				trace("BodyMap: Overriding body of existing color " + color);
			}
			
			_bodiesByColor[color] = body;
			_bodyList.push(body);
		}
		
		public function getBodyByIndex(index:int = 0) : Body
		{
			if (_bodyList.length <= index)
			{
				return null;
			}
			
			return _bodyList[index];
		}
		
		public function hasBodyOfColor(color:uint) : Boolean
		{
			return color in _bodiesByColor;
		}
		
		public function getBodyByColor(color:uint) : Body
		{
			if (color in _bodiesByColor)
			{
				return _bodiesByColor[color]
			}
			
			return null;
		}
		
		public function get bodyCount():int
		{
			return _bodyList.length;
		}
		
		public function setShapeColors(vector:Vector.<uint>) : void
		{
			_shapeColors = vector;
		}
		
		public function get shapeColors() : Vector.<uint>
		{
			return _shapeColors;
		}
		
	}
	
}