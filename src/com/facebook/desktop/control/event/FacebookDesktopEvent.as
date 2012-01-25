package com.facebook.desktop.control.event
{
	import flash.events.Event;

	public class FacebookDesktopEvent extends Event
	{
		public static const USER_LOGGED_IN:String = "userLoggedInEvent";
		public static const USER_LOGGED_OUT:String = "userLoggedOutEvent";
		
		public function FacebookDesktopEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}  // FacebookDesktopEvent
	}  // class declaration
}  // package