package com.facebook.desktop.control.preferences
{
	import com.facebook.desktop.model.Model;
	
	import flash.net.SharedObject;
	
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class PreferencesManager
	{
		private static var model:Model = Model.instance;
		private static var logger:ILogger = Log.getLogger("com.facebook.desktop.control.preferences.PreferencesManager");
		private static var sharedObject:SharedObject;
		
		public static function loadPreferences():void
		{
			sharedObject = SharedObject.getLocal(Model.APPLICATION_ID);
			
			if (sharedObject.data["preferences"])
			{
				logger.info("Loading previously saved preferences");
				model.preferences = sharedObject.data["preferences"];
			}  // if statement
			else
			{
				logger.info("No preferences saved. Creating them now.");
				
				var preferences:Object = new Object();
				preferences.startAtLogin = true;
				preferences.playSound = false;
				preferences.showStoryUpdates = true;
				preferences.showStoryActivity = true;
				preferences.showFriendRequests = true;
				preferences.showMessages = true;
				preferences.showPokes = true;
				preferences.showShares = true;
				preferences.showGroupInvites = true;
				preferences.showEventInvites = true;
				preferences.markNotificationsAsRead = false;
				
				model.preferences = preferences;
				sharedObject.data["preferences"] = preferences;
			}  // else statement
		}  // loadPreferences
		
		public static function savePreferences():void
		{
			logger.info("Saving preferences");
			sharedObject.data["preferences"] = model.preferences;
		}  // savePreferences
		
		public static function getPreference(key:String):Object
		{
			logger.info("Retrieving preferences");
			return sharedObject.data["preferences"][key];
		}  // getPreferences
		
		public static function setPreferences(key:String, value:Object):void
		{
			logger.info("Setting preferences setting {0} = {1}", key, value.toString());
			model.preferences[key] = value;
			sharedObject.data["preferences"][key] = value;
		}  // setPreferences
	}  // class declaration
}  // package