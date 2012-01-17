package com.facebook.desktop.model
{
	import mx.collections.ArrayCollection;
	import mx.resources.ResourceManager;

	public class Model
	{
		public static const APPLICATION_ID:String = "95615112563";
		public static const REQUIRED_PERMISSIONS:Array = ["manage_notifications", "user_about_me", "friends_birthday", "read_stream", "read_mailbox", "read_requests", "read_insights", "publish_stream", "publish_checkins", "user_events", "user_groups", "offline_access", "user_checkins"];
		public static const MAX_ACTIVE_TOASTS:int = 5;
		
		[Bindable] public var connected:Boolean;
		[Bindable] public var paused:Boolean;
		[Bindable] public var locales:Array = [{label:ResourceManager.getInstance().getString('resources','language.english').toString(), locale:"en_US", toolTip:"English"},
											   {label:ResourceManager.getInstance().getString('resources','language.malay').toString(), locale:"ms_MY", toolTip:"Malay"},
											   {label:ResourceManager.getInstance().getString('resources','language.bosnian').toString(), locale:"bs_BA", toolTip:"Bosnian"},
											   {label:ResourceManager.getInstance().getString('resources','language.german').toString(), locale:"de_DE", toolTip:"German"},
											   {label:ResourceManager.getInstance().getString('resources','language.spanish').toString(), locale:"es_ES", toolTip:"Spanish"},
											   {label:ResourceManager.getInstance().getString('resources','language.galician').toString(), locale:"ga_ES", toolTip:"Galician"},
											   {label:ResourceManager.getInstance().getString('resources','language.korean').toString(), locale:"ko_KR", toolTip:"Korean"},
											   {label:ResourceManager.getInstance().getString('resources','language.italian').toString(), locale:"it_IT", toolTip:"Italian"},
											   {label:ResourceManager.getInstance().getString('resources','language.leet').toString(), locale:"lt_US", toolTip:"Leet"},
											   {label:ResourceManager.getInstance().getString('resources','language.dutch').toString(), locale:"nl_NL", toolTip:"Dutch"},
											   {label:ResourceManager.getInstance().getString('resources','language.polish').toString(), locale:"pl_PL", toolTip:"Polish"},
											   {label:ResourceManager.getInstance().getString('resources','language.portugese.brazil').toString(), locale:"pt_BR", toolTip:"Portugese (Brazil)"},
											   {label:ResourceManager.getInstance().getString('resources','language.romanian').toString(), locale:"ro_RO", toolTip:"Romanian"},
											   {label:ResourceManager.getInstance().getString('resources','language.russian').toString(), locale:"ru_RU", toolTip:"Russian"},
											   {label:ResourceManager.getInstance().getString('resources','language.turkish').toString(), locale:"tr_TR", toolTip:"Turkish"},
											   {label:ResourceManager.getInstance().getString('resources','language.chinese.simplified.china').toString(), locale:"zh_CN", toolTip:"Simplified Chinese (China)"},
											   {label:ResourceManager.getInstance().getString('resources','language.chinese.traditional.hongKong').toString(), locale:"zh_HK", toolTip:"Traditional Chinese (Hong Kong)"},
											   {label:ResourceManager.getInstance().getString('resources','language.hebrew').toString(), locale:"he_IL", toolTip:"Hebrew"},
											   {label:ResourceManager.getInstance().getString('resources','language.persian').toString(), locale:"fa_IR", toolTip:"Persian"},
											   {label:ResourceManager.getInstance().getString('resources','language.hindi').toString(), locale:"hi_IN", toolTip:"Hindi"}];
		
		public var preferences:Object;
		public var operatingSystem:String;
		
		public var latestNewsFeedUpdate:String;
		public var latestNotificationUpdate:String;
		public var latestMessageUpdate:String;
		public var latestPokeUpdate:String;
		public var latestShareUpdate:String;
		
		public var currentUser:Object;
		
		private static var _instance:Model = new Model(SingletonLock);
		
		public function Model(lock:Class)
		{
			if (lock != SingletonLock)
			{
				throw new Error("Invalid singleton access.  User Model.instance instead.");
			}  // if statement
		}  // Model
		
		public static function get instance():Model
		{
			return _instance;
		}  // instance
	}  // class declaration
}  // package

class SingletonLock {}