package com.facebook.desktop.control.preferences
{
	import com.charlesbihis.engine.notification.NotificationConst;
	import com.charlesbihis.engine.notification.NotificationManager;
	import com.facebook.desktop.model.Model;
	
	import flash.net.SharedObject;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.resources.ResourceManager;

	public class PreferencesManager
	{
		private static var model:Model = Model.instance;
		private static var log:ILogger = Log.getLogger("com.facebook.desktop.control.preferences.PreferencesManager");
		private static var sharedObject:SharedObject;
		
		public static function loadPreferences():void
		{
			sharedObject = SharedObject.getLocal(Model.APPLICATION_ID);
			
			if (sharedObject.data["preferences"])
			{
				log.info("Loading previously saved preferences");
				model.preferences = sharedObject.data["preferences"];
				
				// load up the previously used language, if there is one
				if (model.preferences.language != null)
				{
					ResourceManager.getInstance().localeChain = [model.locales[model.preferences.language].locale];
				}  // if statement
				
				// setting default notification length
				log.info("Configuring preferred notification display length: {0}", model.preferences.notificationDisplayLength);
				NotificationManager.notificationDisplayLength = model.preferences.notificationDisplayLength;
				
				// convert previous version user preferences to new user preferences
				if (model.preferences.showStoryUpdates || model.preferences.showStoryActivity)
				{
					model.preferences.showNewsFeedUpdates = model.preferences.showStoryUpdates;
					model.preferences.showActivityUpdates = model.preferences.showStoryActivity;
					model.preferences.notificationDisplayLength = NotificationConst.DISPLAY_LENGTH_MEDIUM;
				}  // if statement
			}  // if statement
			else
			{
				log.info("No preferences saved. Creating them now.");
				
				var preferences:Object = new Object();
				preferences.language = 0;		// defaults to en_US which is index 0 in model.locales - must remember to change this if we ever put in another language before en_US
				preferences.startAtLogin = true;
				preferences.showNewsFeedUpdates = true;
				preferences.showActivityUpdates = true;
				preferences.showMessages = true;
				preferences.showFriendRequests = true;
				preferences.showShares = true;
				preferences.showGroupInvites = true;
				preferences.showEventInvites = true;
				preferences.showPokes = true;
				preferences.notificationDisplayLength = NotificationConst.DISPLAY_LENGTH_MEDIUM;
				preferences.markNotificationsAsRead = false;
				preferences.playNotificationSound = false;
				
				model.preferences = preferences;
				sharedObject.data["preferences"] = preferences;
			}  // else statement
		}  // loadPreferences
		
		public static function savePreferences():void
		{
			log.info("Saving preferences");
			sharedObject.data["preferences"] = model.preferences;
			
			// force to write object immediately
			sharedObject.flush();
		}  // savePreferences
		
		public static function getPreference(key:String):Object
		{
			log.info("Retrieving preferences");
			return sharedObject.data["preferences"][key];
		}  // getPreferences
		
		public static function setPreferences(key:String, value:Object):void
		{
			log.info("Setting preferences setting {0} = {1}", key, value.toString());
			model.preferences[key] = value;
			sharedObject.data["preferences"][key] = value;
		}  // setPreferences
	}  // class declaration
}  // package