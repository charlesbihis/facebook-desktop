package com.facebook.desktop.control.system
{
	import com.charlesbihis.engine.notification.NotificationManager;
	import com.facebook.desktop.FacebookDesktopConst;
	import com.facebook.desktop.control.Controller;
	import com.facebook.desktop.control.api.GetAdditionalNotifications;
	import com.facebook.desktop.control.api.GetBirthdays;
	import com.facebook.desktop.control.api.GetNewsFeed;
	import com.facebook.desktop.control.api.GetNotifications;
	import com.facebook.desktop.control.util.Util;
	import com.facebook.desktop.model.Model;
	import com.facebook.desktop.model.cache.UserCache;
	import com.facebook.graph.FacebookDesktop;
	
	import flash.desktop.NativeApplication;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.resources.ResourceManager;
	
	public class SystemInteractionManager
	{
		// commands
		private var aboutCommand:NativeMenuItem;
		private var updateStatusCommand:NativeMenuItem;
		private var pausePlayCommand:NativeMenuItem;
		private var checkForUpdatesCommand:NativeMenuItem;
		private var replayLatestFiveUpdatesCommand:NativeMenuItem;
		private var settingsCommand:NativeMenuItem;
		private var loginCommand:NativeMenuItem;
		private var logoutCommand:NativeMenuItem;
		private var exitCommand:NativeMenuItem;
		private var birthdaysCommand:NativeMenuItem;
		private var eventInvitesCommand:NativeMenuItem;
		private var friendRequestsCommand:NativeMenuItem;
		private var groupInvitesCommand:NativeMenuItem;
		private var unreadMessagesCommand:NativeMenuItem;
		private var newPokesCommand:NativeMenuItem;
		private var newSharesCommand:NativeMenuItem;
		private var topSeparator:NativeMenuItem;
		private var middleSeparator:NativeMenuItem;
		private var bottomSeparator:NativeMenuItem;
		
		// properties
		private var supportsSystemTray:Boolean;
		private var supportsDock:Boolean;
		private var trayDockManager:ITrayDockManager;
		private var additionalNotifications:Object;
		private var birthdayNotifications:Array;
		private var model:Model = Model.instance;
		private var userCache:UserCache = UserCache.instance;
		private var controller:Controller = Controller.instance;
		private var notificationManager:NotificationManager = NotificationManager.instance;
		private var log:ILogger = Log.getLogger("com.facebook.desktop.control.system.SystemInteractionManager");
		
		// menus
		private var _onlineMenu:NativeMenu;
		private var _customOnlineMenu:NativeMenu;
		private var _offlineMenu:NativeMenu;
		private var _disconnectedMenu:NativeMenu;
		
		private static var _instance:SystemInteractionManager = new SystemInteractionManager(SingletonLock);
		
		public function SystemInteractionManager(lock:Class):void
		{
			if (lock != SingletonLock)
			{
				throw new Error("Invalid singleton access.  User Model.instance instead.");
			}  // if statement
			
			// listen to changes in language so I can reset the context menus
			ResourceManager.getInstance().addEventListener(Event.CHANGE, languageChangeHandler);
			
			// initialize system properties
			supportsSystemTray = NativeApplication.supportsSystemTrayIcon;
			supportsDock = NativeApplication.supportsDockIcon;
			
			// configure our tray/dock manager
			if (supportsSystemTray)
			{
				trayDockManager = new TrayManager();
			}  // if statement
			else
			{
				trayDockManager = new DockManager();
			}  // else statement
			
			// initialize menus
			_onlineMenu = new NativeMenu();
			_customOnlineMenu = new NativeMenu();
			_offlineMenu = new NativeMenu();
			_disconnectedMenu = new NativeMenu();
			
			// initialize commands
			aboutCommand = new NativeMenuItem(ResourceManager.getInstance().getString("resources", "contextMenu.about"));
			updateStatusCommand = new NativeMenuItem(ResourceManager.getInstance().getString("resources", "contextMenu.updateStatus"));
			pausePlayCommand = new NativeMenuItem(ResourceManager.getInstance().getString("resources", "contextMenu.pause"));
			checkForUpdatesCommand = new NativeMenuItem(ResourceManager.getInstance().getString("resources", "contextMenu.checkForUpdates"));
			replayLatestFiveUpdatesCommand = new NativeMenuItem(ResourceManager.getInstance().getString("resources", "contextMenu.replayLatestFive"));
			settingsCommand = new NativeMenuItem(ResourceManager.getInstance().getString("resources", "contextMenu.settings"));
			loginCommand = new NativeMenuItem(ResourceManager.getInstance().getString("resources", "contextMenu.login"));
			logoutCommand = new NativeMenuItem(ResourceManager.getInstance().getString("resources", "contextMenu.logout"));
			exitCommand = new NativeMenuItem(ResourceManager.getInstance().getString("resources", "contextMenu.exit"));
			birthdaysCommand = new NativeMenuItem("");
			eventInvitesCommand = new NativeMenuItem("");
			friendRequestsCommand = new NativeMenuItem("");
			groupInvitesCommand = new NativeMenuItem("");
			unreadMessagesCommand = new NativeMenuItem("");
			newPokesCommand = new NativeMenuItem("");
			newSharesCommand = new NativeMenuItem("");
			topSeparator = new NativeMenuItem("", true);
			middleSeparator = new NativeMenuItem("", true);
			bottomSeparator = new NativeMenuItem("", true);
			
			// attach event handlers to the commands
			aboutCommand.addEventListener(Event.SELECT, aboutHandler);
			updateStatusCommand.addEventListener(Event.SELECT, updateStatusHandler);
			checkForUpdatesCommand.addEventListener(Event.SELECT, checkForUpdatesHandler);
			replayLatestFiveUpdatesCommand.addEventListener(Event.SELECT, replayLatestFiveUpdatesHandler);
			pausePlayCommand.addEventListener(Event.SELECT, pausePlayHandler);
			settingsCommand.addEventListener(Event.SELECT, settingsHandler);
			logoutCommand.addEventListener(Event.SELECT, logoutHandler);
			loginCommand.addEventListener(Event.SELECT, loginHandler);
			exitCommand.addEventListener(Event.SELECT, exitHandler);
			birthdaysCommand.addEventListener(Event.SELECT, birthdaysHandler);
			eventInvitesCommand.addEventListener(Event.SELECT, eventInvitesHandler);
			friendRequestsCommand.addEventListener(Event.SELECT, friendRequestsHandler);
			groupInvitesCommand.addEventListener(Event.SELECT, groupInvitesHandler);
			unreadMessagesCommand.addEventListener(Event.SELECT, unreadMessagesHandler);
			newPokesCommand.addEventListener(Event.SELECT, newPokesHandler);
			newSharesCommand.addEventListener(Event.SELECT, newSharesHandler);
			
			function languageChangeHandler(event:Event):void
			{
				// static menu items
				aboutCommand.label = ResourceManager.getInstance().getString("resources", "contextMenu.about");
				updateStatusCommand.label = ResourceManager.getInstance().getString("resources", "contextMenu.updateStatus");
				pausePlayCommand.label = ResourceManager.getInstance().getString("resources", "contextMenu.pause");
				checkForUpdatesCommand.label = ResourceManager.getInstance().getString("resources", "contextMenu.checkForUpdates");
				replayLatestFiveUpdatesCommand.label = ResourceManager.getInstance().getString("resources", "contextMenu.replayLatestFive");
				settingsCommand.label = ResourceManager.getInstance().getString("resources", "contextMenu.settings");
				loginCommand.label = ResourceManager.getInstance().getString("resources", "contextMenu.login");
				logoutCommand.label = ResourceManager.getInstance().getString("resources", "contextMenu.logout");
				exitCommand.label = ResourceManager.getInstance().getString("resources", "contextMenu.exit");
				
				// dynamic menu items
				if (additionalNotifications != null)
				{
					eventInvitesCommand.label = additionalNotifications.event_invites.length == 1 ? ResourceManager.getInstance().getString("resources", "notification.eventInvitation") : ResourceManager.getInstance().getString("resources", "notification.eventInvitationsBegin") + " " + additionalNotifications.event_invites.length + " " + ResourceManager.getInstance().getString("resources", "notification.eventInvitationsEnd");
					friendRequestsCommand.label = additionalNotifications.friend_requests.length == 1 ? ResourceManager.getInstance().getString("resources", "notification.friendRequest") : ResourceManager.getInstance().getString("resources", "notification.friendRequestsBegin") + " " + additionalNotifications.friend_requests.length + " " + ResourceManager.getInstance().getString("resources", "notification.friendRequestsEnd");
					groupInvitesCommand.label = additionalNotifications.group_invites.length == 1 ? ResourceManager.getInstance().getString("resources", "notification.groupInvitation") : ResourceManager.getInstance().getString("resources", "notification.groupInvitationsBegin") + " " + additionalNotifications.group_invites.length + " " + ResourceManager.getInstance().getString("resources", "notification.groupInvitationsEnd");
					unreadMessagesCommand.label = additionalNotifications.messages.unread == 1 ? ResourceManager.getInstance().getString("resources", "notification.unreadMessage") : ResourceManager.getInstance().getString("resources", "notification.unreadMessagesBegin") + " " + additionalNotifications.messages.unread + " " + ResourceManager.getInstance().getString("resources", "notification.unreadMessagesEnd");
					newPokesCommand.label = ResourceManager.getInstance().getString("resources", "notification.poked");
					newSharesCommand.label = ResourceManager.getInstance().getString("resources", "notification.sharedLink");
				}  // if statement
			}  // languageChangeHandler
		}  // SystemInteractionManager
		
		public static function get instance():SystemInteractionManager
		{
			return _instance;
		}  // instance
		
		public function get onlineMenu():NativeMenu
		{
			clearMenus();
			
			// initialize the online state menus
			_onlineMenu.addItem(aboutCommand);
			_onlineMenu.addItem(updateStatusCommand);
			_onlineMenu.addItem(topSeparator);
			_onlineMenu.addItem(checkForUpdatesCommand);
			_onlineMenu.addItem(replayLatestFiveUpdatesCommand);
			_onlineMenu.addItem(pausePlayCommand);
			_onlineMenu.addItem(bottomSeparator);
			_onlineMenu.addItem(settingsCommand);
			_onlineMenu.addItem(logoutCommand);
			_onlineMenu.addItem(exitCommand);
			
			return _onlineMenu;
		}  // onlineMenu
		
		public function get offlineMenu():NativeMenu
		{
			clearMenus();
			if (_onlineMenu.containsItem(aboutCommand))
			_onlineMenu.removeItem(aboutCommand);
			
			// initialize the offline state menus
			_offlineMenu.addItem(aboutCommand);
			_offlineMenu.addItem(topSeparator);
			_offlineMenu.addItem(settingsCommand);
			_offlineMenu.addItem(loginCommand);
			_offlineMenu.addItem(exitCommand);
			
			return _offlineMenu;
		}  // offlineMenu
		
		public function get disconnectedMenu():NativeMenu
		{
			clearMenus();
			
			// initialize the disconnected state menus
			_disconnectedMenu.addItem(aboutCommand);
			_disconnectedMenu.addItem(topSeparator);
			_disconnectedMenu.addItem(exitCommand);
			
			return _disconnectedMenu;
		}  // disconnectedMenu
		
		private function clearMenus():void
		{
			_onlineMenu.removeAllItems();
			_offlineMenu.removeAllItems();
			_disconnectedMenu.removeAllItems();
			_customOnlineMenu.removeAllItems();
		}  // clearMenus
		
		public function changeApplicationState(state:String):void
		{
			trayDockManager.changeState(state);
		}  // changeApplicationState
		
		private function addCustomItemsToMenu():void
		{
			setCustomMenuCommandLabels();
			
			var notificationCount:int = 0;
			clearMenus();
			
			// re-build bottom menu items
			_customOnlineMenu.addItem(aboutCommand);
			_customOnlineMenu.addItem(updateStatusCommand);
			_customOnlineMenu.addItem(topSeparator);
			_customOnlineMenu.addItem(checkForUpdatesCommand);
			_customOnlineMenu.addItem(replayLatestFiveUpdatesCommand);
			_customOnlineMenu.addItem(pausePlayCommand);
			
			// insert middle menu items
			if ((birthdayNotifications != null && birthdayNotifications.length > 0) || 
				(additionalNotifications != null && (additionalNotifications.event_invites.length > 0 || additionalNotifications.friend_requests.length > 0 || additionalNotifications.group_invites.length > 0 ||
				additionalNotifications.messages.unread > 0 || additionalNotifications.pokes.unread > 0 || additionalNotifications.shares.unread > 0)))
			{
				_customOnlineMenu.addItem(middleSeparator);
				
				// birthdays
				if (birthdayNotifications != null && birthdayNotifications is Array && birthdayNotifications.length > 0)
				{
					// Note: We are *not* changing the icon to notification-waiting for birthdays because
					//       we don't want users icons to be forever in the notification-waiting state
					//       whenever they have a friend whose birthday is today.
					_customOnlineMenu.addItem(birthdaysCommand);
				}  // if statement
				
				// event invites
				if (additionalNotifications.event_invites != null && additionalNotifications.event_invites.length > 0)
				{
					_customOnlineMenu.addItem(eventInvitesCommand);
					notificationCount += additionalNotifications.event_invites.length;
				}  // if statement
				
				// friend requests
				if (additionalNotifications.friend_requests != null && additionalNotifications.friend_requests.length > 0)
				{
					_customOnlineMenu.addItem(friendRequestsCommand);
					notificationCount += additionalNotifications.event_invites.length;
				}  // if statement
				
				// group invites
				if (additionalNotifications.group_invites != null && additionalNotifications.group_invites.length > 0)
				{
					_customOnlineMenu.addItem(groupInvitesCommand);
					notificationCount += additionalNotifications.group_invites.length;
				}  // if statement
				
				// unread messages
				if (additionalNotifications.messages != null && additionalNotifications.messages.unread > 0)
				{
					_customOnlineMenu.addItem(unreadMessagesCommand);
					notificationCount += additionalNotifications.messages.unread;
				}  // if statement
				
				// pokes
				if (additionalNotifications.pokes != null && additionalNotifications.pokes.unread > 0)
				{
					_customOnlineMenu.addItem(newPokesCommand);
					notificationCount += additionalNotifications.pokes.unread;
				}  // if statement
				
				// shares
				if (additionalNotifications.shares != null && additionalNotifications.shares.unread > 0)
				{
					_customOnlineMenu.addItem(newSharesCommand);
					notificationCount += additionalNotifications.shares.unread;
				}  // if statement
			}  // if statement
			
			// re-build bottom menu items
			_customOnlineMenu.addItem(bottomSeparator);
			_customOnlineMenu.addItem(settingsCommand);
			_customOnlineMenu.addItem(logoutCommand);
			
			// only add this item to system-tray menu since dock menu already has an "Quit" option
			if (supportsSystemTray)
			{
				_customOnlineMenu.addItem(exitCommand);
			}  // if statement
			
			trayDockManager.changeMenu(_customOnlineMenu);
			
			// change icon to show that there are notifications waiting
			if (notificationCount > 0)
			{
				// TODO: change icon to actually show notificationCount
				trayDockManager.changeIcon(supportsSystemTray ? FacebookDesktopConst.FACEBOOK_DESKTOP_NOTIFICATION_WAITING_TRAY_ICON : FacebookDesktopConst.FACEBOOK_DESKTOP_NOTIFICATION_WAITING_DOCK_ICON);
			}  // if statement
		}  // addCustomItemsToMenu
		
		private function setCustomMenuCommandLabels():void
		{
			// set birthdays-command label
			if (birthdayNotifications != null && birthdayNotifications.length > 0)
			{
				birthdaysCommand.label = (birthdayNotifications.length == 1 ? ResourceManager.getInstance().getString("resources", "notification.birthday") : ResourceManager.getInstance().getString("resources", "notification.birthdaysBegin") + " " + birthdayNotifications.length + " " + ResourceManager.getInstance().getString("resources", "notification.birthdaysEnd"));
			}  // if statement
			
			// set event-invites-command label
			if (additionalNotifications.event_invites != null && additionalNotifications.event_invites.length > 0)
			{
				eventInvitesCommand.label = (additionalNotifications.event_invites.length == 1) ? ResourceManager.getInstance().getString("resources", "notification.eventInvitation") : ResourceManager.getInstance().getString("resources", "notification.eventInvitationsBegin") + " " + additionalNotifications.event_invites.length + " " + ResourceManager.getInstance().getString("resources", "notification.eventInvitationsEnd");
			}  // if statement
			
			// set friend-requests-command label
			if (additionalNotifications.friend_requests != null && additionalNotifications.friend_requests.length > 0)
			{
				friendRequestsCommand.label = (additionalNotifications.friend_requests.length == 1) ? ResourceManager.getInstance().getString("resources", "notification.friendRequest") : ResourceManager.getInstance().getString("resources", "notification.friendRequestsBegin") + " " + additionalNotifications.friend_requests.length + " " + ResourceManager.getInstance().getString("resources", "notification.friendRequestsEnd");
			}  // if statement
			
			// set group-invites-command label
			if (additionalNotifications.group_invites != null && additionalNotifications.group_invites.length > 0)
			{
				groupInvitesCommand.label = (additionalNotifications.group_invites.length == 1) ? ResourceManager.getInstance().getString("resources", "notification.groupInvitation") : ResourceManager.getInstance().getString("resources", "notification.groupInvitationsBegin") + " " + additionalNotifications.group_invites.length + " " + ResourceManager.getInstance().getString("resources", "notification.groupInvitationsEnd");
			}  // if statement
			
			// set unread-messages-command label
			if (additionalNotifications.messages != null && additionalNotifications.messages.unread > 0)
			{
				unreadMessagesCommand.label = (additionalNotifications.messages.unread == 1) ? ResourceManager.getInstance().getString("resources", "notification.unreadMessage") : ResourceManager.getInstance().getString("resources", "notification.unreadMessagesBegin") + " " + additionalNotifications.messages.unread + " " + ResourceManager.getInstance().getString("resources", "notification.unreadMessagesEnd");
			}  // if statement
			
			// set pokes-command label
			if (additionalNotifications.pokes != null && additionalNotifications.pokes.unread > 0)
			{
				newPokesCommand.label = ResourceManager.getInstance().getString("resources", "notification.poked");
			}  // if statement
			
			if (additionalNotifications.shares != null && additionalNotifications.shares.unread > 0)
			{
				newSharesCommand.label = ResourceManager.getInstance().getString("resources", "notification.sharedLink");
			}  // if statement
		}  // setCustomMenuCommandLabels

		public function addBirthdaysToMenu(birthdayNotifications:Array):void
		{
			this.birthdayNotifications = birthdayNotifications;
			addCustomItemsToMenu();
		}  // addBirthdaysToMenu
		
		public function addAdditionalNotificationsToMenu(additionalNotifications:Object):void
		{
			this.additionalNotifications = additionalNotifications;
			addCustomItemsToMenu();
		}  // addAdditionalNotificationsToMenu
		
		private function aboutHandler(event:Event = null):void
		{
			controller.openAboutWindow();
		}  // aboutHandler
		
		private function updateStatusHandler(event:Event = null):void
		{
			// only show update-window if we're connected
			if (model.connected && model.currentUser != null)
			{
				log.info("Attempting to show/hide status-update window");
				controller.openStatusUpdateWindow();
			}  // if statement
			else
			{
				log.info("System-tray/dock icon clicked but user not logged in. Suppressing display of status-update window.");
			}  // else statement
		}  // updateStatusHandler
		
		private function loginHandler(event:Event = null):void
		{
			log.info("Logging in...");
			FacebookDesktop.login(loginHandler, Model.REQUIRED_PERMISSIONS);
			
			function loginHandler(session:Object, fail:Object):void
			{
				if (session != null)
				{
					log.info("Login from system-tray successful");
					
					// store the user
					model.currentUser = session.user;
					
					// adjust icon and menus
					trayDockManager.changeState(SystemState.ONLINE);
					
					// show login popup
					notificationManager.show(ResourceManager.getInstance().getString("resources", "toast.welcome"), "", FacebookDesktop.getImageUrl(session.user.id), FacebookDesktopConst.FACEBOOK_DESKTOP_PAGE);
					notificationManager.clearLatestFiveUpdates();
					
					// get latest update so that we can start receiving pop-ups for *new* updates
					FacebookDesktop.api("/me/home", getNewsFeedHandler, {limit:1});
				}  // if statement
			}  // loginHandler
			
			function getNewsFeedHandler(result:Object, fail:Object):void
			{
				if (fail == null && result != null && result is Array && (result as Array).length > 0)
				{
					// set latest-story-update time
					var latestNewsFeedUpdate:Date = Util.RFC3339toDate(result[0].created_time);
					log.info("Setting latest news feed update time to " + (latestNewsFeedUpdate.time / 1000));
					model.latestNewsFeedUpdate = (latestNewsFeedUpdate.time / 1000).toString();
					
					// likes, comments, and group posts
					var getNotificationsCommand:GetNotifications = new GetNotifications();
					getNotificationsCommand.execute();
					
					// messages, pokes, shares, friend-requests, group-invites, and event-invites
					var getAdditionalNotificationsCommand:GetAdditionalNotifications = new GetAdditionalNotifications();
					getAdditionalNotificationsCommand.execute(null, null, {isStartup:true});
				}  // if statement
				else
				{
					log.error("Request to get latest update has failed!  Error object: " + fail);
				}  // else statement
			}  // getNewsFeedHandler
		}  // loginHandler
		
		private function logoutHandler(event:Event = null):void
		{
			log.info("Logging out! Goodbye!");
			
			trayDockManager.changeState(SystemState.OFFLINE);
			notificationManager.show(ResourceManager.getInstance().getString("resources", "toast.goodbye"), "", FacebookDesktopConst.FACEBOOK_NOTIFICATION_DEFAULT_IMAGE);
			
			// clear toast-history
			notificationManager.clearLatestFiveUpdates();
			model.currentUser = null;
			additionalNotifications = null;
			
			FacebookDesktop.logout();
		}  // logoutHandler
		
		private function settingsHandler(event:Event = null):void
		{
			controller.openSettingsWindow();
		}  // settingsHandler
		
		private function pausePlayHandler(event:Event = null):void
		{
			// if resuming, let's re-fetch all of the custom notification
			if (model.paused)
			{
				var getAdditionalNotificationsCommand:GetAdditionalNotifications = new GetAdditionalNotifications();
				getAdditionalNotificationsCommand.execute();
			}  // if statement
			
			trayDockManager.changeState(model.paused ? SystemState.ONLINE : SystemState.PAUSED);
			pausePlayCommand.label = (model.paused ? ResourceManager.getInstance().getString("resources", "contextMenu.resume") : ResourceManager.getInstance().getString("resources", "contextMenu.pause"));
		}  // pausePlayHandler
		
		private function checkForUpdatesHandler(event:Event = null):void
		{
			log.info("Forcing a check for updates");
			
			var totalUpdates:int = 0;
			
			// news feed updates
			var getNewsFeedCommand:GetNewsFeed = new GetNewsFeed();
			getNewsFeedCommand.execute({since:model.latestNewsFeedUpdate}, getNewsFeedHandler);
			
			function getNewsFeedHandler(result:Object, fail:Object, passThroughArgs:Object = null):void
			{
				if (fail == null && result != null && result is Array && (result as Array).length > 0)
				{
					totalUpdates += (result as Array).length;
				}  // if statement
				
				// likes, comments, and group posts
				var getNotificationsCommand:GetNotifications = new GetNotifications();
				getNotificationsCommand.execute({since:model.latestNotificationUpdate}, getNotificationsHandler);
			}  // getNewsFeedHandler
			
			function getNotificationsHandler(result:Object, fail:Object, passThroughArgs:Object = null):void
			{
				if (fail == null && result != null && result is Array && (result as Array).length > 0)
				{
					totalUpdates += (result as Array).length;
				}  // if statement
				
				// messages, pokes, shares, friend-requests, group-invites, and event-invites
				var getAdditionalNotificationsCommand:GetAdditionalNotifications = new GetAdditionalNotifications();
				getAdditionalNotificationsCommand.execute(null, getAdditionalNotificationsHandler);
			}  // getNotificationsHandler
			
			function getAdditionalNotificationsHandler(result:Object, fail:Object, passThroughArgs:Object = null):void
			{
				if (fail == null && result != null)
				{
					// Note: We are ignoring event invites, friend requests, and group invites because of the
					//       way they are returned from the Facebook REST APIs.  They only return a count, which
					//       doesn't tell us if there are any *new* event invites, friend requests, or group
					//       invites.  Hopefully, they fix this when they convert this to the Graph APIs.
					
					// messages
					if (model.preferences.showMessages && result.messages != null && result.messages.most_recent > model.latestMessageUpdate)
					{
						totalUpdates += result.messages.unread;
					}  // if statement
					
					// pokes
					if (model.preferences.showPokes && result.pokes != null && result.pokes.most_recent > model.latestPokeUpdate)
					{
						totalUpdates += result.pokes.unread;
					}  // if statement
					
					// shares
					if (model.preferences.showShares && result.shares != null && result.shares.most_recent > model.latestShareUpdate)
					{
						totalUpdates += result.shares.unread;
					}  // if statement
					
					// if there were no updates, let the user know we checked
					if (totalUpdates == 0)
					{
						log.info("No new updates to show");
						notificationManager.show(ResourceManager.getInstance().getString("resources", "toast.noNewUpdates"), "", "/assets/images/toast/icon50.png", null, false, false, false);
					}  // if statement
				}  // if statement
			}  // getAdditionalNotificationsHandler
		}  // checkForUpdatesHandler
		
		private function replayLatestFiveUpdatesHandler(event:Event = null):void
		{
			log.info("Displaying latest 5 updates");
			notificationManager.replayLatestFiveUpdates();
		}  // replayLatestFiveUpdatesHandler
		
		private function exitHandler(event:Event = null):void
		{
			log.info("Exiting the application.");
			NativeApplication.nativeApplication.exit();
		}  // exitHandler
		
		private function birthdaysHandler(event:Event):void
		{
			log.info("Context menu click - showing birthday's again");
			var getBirthdays:GetBirthdays = new GetBirthdays();
			getBirthdays.execute(null, null, {contextMenuClick:true});
		}  // birthdaysHandler
		
		private function eventInvitesHandler(event:Event):void
		{
			log.info("Context menu click - viewing event invites");
			flash.net.navigateToURL(new URLRequest(FacebookDesktopConst.FACEBOOK_EVENT_INVITES_URL));
		}  // eventInvitesHandler
		
		private function friendRequestsHandler(event:Event):void
		{
			log.info("Context menu click - viewing friend requests");
			flash.net.navigateToURL(new URLRequest(FacebookDesktopConst.FACEBOOK_FRIEND_REQUESTS_URL));
		}  // friendRequestsHandler
		
		private function groupInvitesHandler(event:Event):void
		{
			log.info("Context menu click - viewing group invites");
			flash.net.navigateToURL(new URLRequest(FacebookDesktopConst.FACEBOOK_GROUP_INVITES_URL));
		}  // groupInvitesHandler
		
		private function unreadMessagesHandler(event:Event):void
		{
			log.info("Context menu click - viewing unread messages");
			flash.net.navigateToURL(new URLRequest(FacebookDesktopConst.FACEBOOK_MESSAGES_URL));
		}  // unreadMessagesHandler
		
		private function newPokesHandler(event:Event):void
		{
			log.info("Context menu click - viewing new pokes");
			flash.net.navigateToURL(new URLRequest(FacebookDesktopConst.FACEBOOK_POKES_URL));
		}  // newPokesHandler
		
		private function newSharesHandler(event:Event):void
		{
			log.info("Context menu click - viewing new shares");
			flash.net.navigateToURL(new URLRequest(FacebookDesktopConst.FACEBOOK_SHARES_URL));
		}  // newSharesHandler
	}  // class declaration
}  // package

class SingletonLock {}