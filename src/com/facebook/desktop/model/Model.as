package com.facebook.desktop.model
{
	import mx.collections.ArrayCollection;

	public class Model
	{
		public static const APPLICATION_ID:String = "95615112563";
		public static const REQUIRED_PERMISSIONS:Array = ["user_about_me", "friends_birthday", "read_stream", "read_mailbox", "read_requests", "read_insights", "publish_stream", "publish_checkins", "user_events", "user_groups", "offline_access", "user_checkins"];
		public static const MAX_ACTIVE_TOASTS:int = 5;
		
		[Bindable] public var connected:Boolean;
		[Bindable] public var paused:Boolean;
		
		public var preferences:Object;
		public var operatingSystem:String;
		
		public var latestStreamUpdate:String;
		public var latestMessageUpdate:String;
		public var latestPokeUpdate:String;
		public var latestShareUpdate:String;
		public var latestActivityUpdate:String;
		public var latestFiveUpdates:ArrayCollection;
		public var activeToasts:ArrayCollection;
		
		private static var _instance:Model = new Model(SingletonLock);
		
		public function Model(lock:Class)
		{
			if (lock != SingletonLock)
			{
				throw new Error("Invalid singleton access.  User Model.instance instead.");
			}  // if statement
			
			latestFiveUpdates = new ArrayCollection();
			activeToasts = new ArrayCollection();
		}  // Model
		
		public static function get instance():Model
		{
			return _instance;
		}  // instance
	}  // class declaration
}  // package

class SingletonLock {}