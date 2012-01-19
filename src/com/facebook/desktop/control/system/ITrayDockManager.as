package com.facebook.desktop.control.system
{
	import flash.display.NativeMenu;

	public interface ITrayDockManager
	{
		function changeState(state:String):void;
		function changeStateManually(menu:NativeMenu, iconPath:String, toolTip:String = null):void;
		function changeMenu(menu:NativeMenu):void;
		function changeIcon(icon:String):void;
		function changeToolTip(toolTip:String):void;
	}  // interface declaration
}  // package