package com.facebook.desktop.control.api
{
	import flash.events.IEventDispatcher;

	public interface ICommand
	{
		function execute(args:Object, passThroughArgs:Object):void;
	}
}