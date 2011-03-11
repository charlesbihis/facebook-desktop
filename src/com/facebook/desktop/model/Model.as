package com.facebook.desktop.model
{
	import mx.collections.ArrayCollection;
	import mx.resources.ResourceManager;

	public class Model
	{
		public static const APPLICATION_ID:String = "95615112563";
		public static const REQUIRED_PERMISSIONS:Array = ["user_about_me", "friends_birthday", "read_stream", "read_mailbox", "read_requests", "read_insights", "publish_stream", "publish_checkins", "user_events", "user_groups", "offline_access", "user_checkins"];
		public static const MAX_ACTIVE_TOASTS:int = 5;
		
		[Bindable] public var connected:Boolean;
		[Bindable] public var paused:Boolean;
		[Bindable] public var locales:Array = [{label:ResourceManager.getInstance().getString('resources','language.english').toString(), locale:"en_US"},
											   {label:ResourceManager.getInstance().getString('resources','language.bosnian').toString(), locale:"bs_BA"},
											   {label:ResourceManager.getInstance().getString('resources','language.chinese').toString(), locale:"zh_CN"},
											   {label:ResourceManager.getInstance().getString('resources','language.dutch').toString(), locale:"nl_NL"},
											   {label:ResourceManager.getInstance().getString('resources','language.german').toString(), locale:"de_DE"},
											   {label:ResourceManager.getInstance().getString('resources','language.hebrew').toString(), locale:"he_IL"},
											   {label:ResourceManager.getInstance().getString('resources','language.hindi').toString(), locale:"hi_IN"},
											   {label:ResourceManager.getInstance().getString('resources','language.italian').toString(), locale:"it_IT"},
											   {label:ResourceManager.getInstance().getString('resources','language.malay').toString(), locale:"ms_MY"},
											   {label:ResourceManager.getInstance().getString('resources','language.polish').toString(), locale:"pl_PL"},
											   {label:ResourceManager.getInstance().getString('resources','language.russian').toString(), locale:"ru_RU"},
											   {label:ResourceManager.getInstance().getString('resources','language.spanish').toString(), locale:"es_ES"},
											   {label:ResourceManager.getInstance().getString('resources','language.turkish').toString(), locale:"tr_TR"}]; 
		
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