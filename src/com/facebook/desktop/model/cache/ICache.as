package com.facebook.desktop.model.cache
{
	public interface ICache
	{
		function get(key:String):Object;
		function put(key:String, value:Object):void;
		function contains(key:String):Boolean;
	}  // interface declaration
}  // package