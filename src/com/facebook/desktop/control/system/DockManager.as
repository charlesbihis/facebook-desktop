package com.facebook.desktop.control.system
{
	import flash.display.NativeMenu;
	
	public class DockManager implements ITrayDockManager
	{
		public function DockManager()
		{
			// TODO: do not add an exit menu item since default dock menu already has it
		}
		
		public function changeState(state:String):void
		{
		}
		
		public function changeStateManually(menu:NativeMenu, iconPath:String, toolTip:String = null):void
		{
		}
		
		public function changeMenu(menu:NativeMenu):void
		{
		}
		
		public function changeIcon(icon:String):void
		{
		}
		
		public function changeToolTip(toolTip:String):void
		{
		}
	}
}