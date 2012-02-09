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
				
				// set defaults for new preference properties
				if (model.preferences.language == null)
				{
					model.preferences.language = 0;
				}  // if statement
				if (model.preferences.startAtLogin == null)
				{
					model.preferences.startAtLogin = true;
				}  // if statement
				if (model.preferences.showNewsFeedUpdates == null)
				{
					model.preferences.showNewsFeedUpdates = true;
				}  // if statement
				if (model.preferences.showActivityUpdates == null)
				{
					model.preferences.showActivityUpdates = true;
				}  // if statement
				if (model.preferences.showMessages == null)
				{
					model.preferences.showMessages = false;
				}  // if statement
				if (model.preferences.showFriendRequests == null)
				{
					model.preferences.showFriendRequests = true;
				}  // if statement
				if (model.preferences.showShares == null)
				{
					model.preferences.showShares = true;
				}  // if statement
				if (model.preferences.showGroupInvites == null)
				{
					model.preferences.showGroupInvites = true;
				}  // if statement
				if (model.preferences.showEventInvites == null)
				{
					model.preferences.showEventInvites = true;
				}  // if statement
				if (model.preferences.showPokes == null)
				{
					model.preferences.showPokes = true;
				}  // if statement
				if (model.preferences.showBirthdays == null)
				{
					model.preferences.showBirthdays = true;
				}  // if statement
				if (model.preferences.showNewsFeedUpdatesSticky == null)
				{
					model.preferences.showNewsFeedUpdatesSticky = false;
				}  // if statement
				if (model.preferences.showActivityUpdatesSticky == null)
				{
					model.preferences.showActivityUpdatesSticky = false;
				}  // if statement
				if (model.preferences.showMessagesSticky == null)
				{
					model.preferences.showMessagesSticky = false;
				}  // if statement
				if (model.preferences.showFriendRequestsSticky == null)
				{
					model.preferences.showFriendRequestsSticky = false;
				}  // if statement
				if (model.preferences.showSharesSticky == null)
				{
					model.preferences.showSharesSticky = false;
				}  // if statement
				if (model.preferences.showGroupInvitesSticky == null)
				{
					model.preferences.showGroupInvitesSticky = false;
				}  // if statement
				if (model.preferences.showEventInvitesSticky == null)
				{
					model.preferences.showEventInvitesSticky = false;
				}  // if statement
				if (model.preferences.showPokesSticky == null)
				{
					model.preferences.showPokesSticky = false;
				}  // if statement
				if (model.preferences.showBirthdaysSticky == null)
				{
					model.preferences.showBirthdaysSticky = true;
				}  // if statement
				if (model.preferences.notificationDisplayLength == null)
				{
					model.preferences.notificationDisplayLength = NotificationConst.DISPLAY_LENGTH_MEDIUM;
				}  // if statement
				if (model.preferences.iconClickAction == null)
				{
					model.preferences.iconClickAction = 0;
				}  // if statement
				if (model.preferences.theme == null)
				{
					model.preferences.theme = 0;
				}  // if statement
				if (model.preferences.markNotificationsAsRead == null)
				{
					model.preferences.markNotificationsAsRead = false;
				}  // if statement
				if (model.preferences.playNotificationSound == null)
				{
					model.preferences.playNotificationSound = false;
				}  // if statement
			}  // if statement
			else
			{
				log.info("No preferences saved. Creating them now.");
				
				var preferences:Object = new Object();
				
				// application settings
				preferences.language = 0;			// defaults to en_US which is index 0 in model.locales - must remember to change this if we ever put in another language before en_US
				preferences.startAtLogin = true;
				
				// notification settings
				preferences.showNewsFeedUpdates = true;
				preferences.showActivityUpdates = true;
				preferences.showMessages = true;
				preferences.showFriendRequests = true;
				preferences.showShares = true;
				preferences.showGroupInvites = true;
				preferences.showEventInvites = true;
				preferences.showPokes = true;
				preferences.showBirthdays = true;
				preferences.showNewsFeedUpdatesSticky = false;
				preferences.showActivityUpdatesSticky = false;
				preferences.showMessagesSticky = true;
				preferences.showFriendRequestsSticky = true;
				preferences.showSharesSticky = true;
				preferences.showGroupInvitesSticky = true;
				preferences.showEventInvitesSticky = true;
				preferences.showPokesSticky = true;
				preferences.showBirthdaysSticky = true;
				
				// advanced settings
				preferences.notificationDisplayLength = NotificationConst.DISPLAY_LENGTH_MEDIUM;
				preferences.iconClickAction = 0;	// defaults to opening the status update window which is index 0 in model.clickActions
				preferences.theme = 0;				// defaults to "Dark" theme which is index 0 in model.themes
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