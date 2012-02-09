package com.facebook.desktop.control.api
{
	import com.charlesbihis.engine.notification.NotificationManager;
	import com.charlesbihis.engine.notification.ui.Notification;
	import com.facebook.desktop.FacebookDesktopConst;
	import com.facebook.desktop.control.system.SystemInteractionManager;
	import com.facebook.desktop.model.Model;
	import com.facebook.graph.FacebookDesktop;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.resources.ResourceManager;
	import mx.utils.ObjectUtil;

	public class GetAdditionalNotifications implements ICommand
	{
		private static const API:String = "notifications.get";
		
		private var model:Model = Model.instance;
		private var systemInteractionManager:SystemInteractionManager = SystemInteractionManager.instance;
		private var log:ILogger = Log.getLogger("com.facebook.desktop.control.api.GetAdditionalNotifications");
		
		public function execute(args:Object = null, callback:Function = null, passThroughArgs:Object = null):void
		{
			FacebookDesktop.callRestAPI(API, getAdditionalNotificationsHandler);
			
			function getAdditionalNotificationsHandler(result:Object, fail:Object):void
			{
				if (fail == null && result != null && result.error_code == null)
				{
					// event invites
					if (model.preferences.showEventInvites && result.event_invites != null && result.event_invites is Array && result.event_invites.length > 0)
					{
						// if this is our first application call, display a summary notification
						if (passThroughArgs != null && passThroughArgs.source == FacebookDesktopConst.STARTUP)
						{
							var startupEventInvitesMessage:String = (result.event_invites.length == 1 ? ResourceManager.getInstance().getString("resources", "notification.eventInvitation") : ResourceManager.getInstance().getString("resources", "notification.eventInvitationsBegin") + " " + result.event_invites.length + " " + ResourceManager.getInstance().getString("resources", "notification.eventInvitationsEnd"));
							log.info("Startup notification! - {0}", startupEventInvitesMessage);
							
							var eventInviteNotification:Notification = new Notification();
							eventInviteNotification.title = startupEventInvitesMessage;
							eventInviteNotification.image = FacebookDesktopConst.FACEBOOK_EVENT_INVITES_ICON;
							eventInviteNotification.link = FacebookDesktopConst.FACEBOOK_EVENT_INVITES_URL;
							eventInviteNotification.isCompact = true;
							eventInviteNotification.isSticky = model.preferences.showEventInvitesSticky;
							model.notificationManager.showNotification(eventInviteNotification);
						}  // if statement
					}  // if statement
					
					// friend requests
					if (model.preferences.showFriendRequests && result.friend_requests != null && result.friend_requests is Array && result.friend_requests.length > 0)
					{
						// if this is our first application call, display a summary notification
						if (passThroughArgs != null && passThroughArgs.source == FacebookDesktopConst.STARTUP)
						{
							var startupFriendRequestsMessage:String = (result.friend_requests.length == 1 ? ResourceManager.getInstance().getString("resources", "notification.friendRequest") : ResourceManager.getInstance().getString("resources", "notification.friendRequestsBegin") + " " + result.event_invites.length + " " + ResourceManager.getInstance().getString("resources", "notification.friendRequestsEnd"));
							log.info("Startup notification! - {0}", startupFriendRequestsMessage);
							
							var friendRequestsNotification:Notification = new Notification();
							friendRequestsNotification.title = startupFriendRequestsMessage;
							friendRequestsNotification.image = FacebookDesktopConst.FACEBOOK_FRIEND_REQUESTS_ICON;
							friendRequestsNotification.link = FacebookDesktopConst.FACEBOOK_FRIEND_REQUESTS_URL;
							friendRequestsNotification.isCompact = true;
							friendRequestsNotification.isSticky = model.preferences.showFriendRequestsSticky;
							model.notificationManager.showNotification(friendRequestsNotification);
						}  // if statement
					}  // if statement
					
					// group invites
					if (model.preferences.showGroupInvites && result.group_invites != null && result.group_invites is Array && result.group_invites.length > 0)
					{
						// if this is our first application call, display a summary notification
						if (passThroughArgs != null && passThroughArgs.source == FacebookDesktopConst.STARTUP)
						{
							var startupGroupInvitesMessage:String = (result.group_invites.length == 1 ? ResourceManager.getInstance().getString("resources", "notification.groupInvitation") : ResourceManager.getInstance().getString("resources", "notification.groupInvitationsBegin") + " " + result.group_invites.length + " " + ResourceManager.getInstance().getString("resources", "notification.groupInvitationsEnd"));
							log.info("Startup notification! - {0}", startupGroupInvitesMessage);
							
							var groupInvitesNotification:Notification = new Notification();
							groupInvitesNotification.title = startupGroupInvitesMessage;
							groupInvitesNotification.image = FacebookDesktopConst.FACEBOOK_GROUP_INVITES_ICON;
							groupInvitesNotification.link = FacebookDesktopConst.FACEBOOK_GROUP_INVITES_URL;
							groupInvitesNotification.isCompact = true;
							groupInvitesNotification.isSticky = model.preferences.showGroupInvitesSticky;
							model.notificationManager.showNotification(groupInvitesNotification);
						}  // if statement
					}  // if statement
					
					// messages
					var messages:Object = result.messages;
					if (model.preferences.showMessages && messages != null && messages.most_recent > model.latestMessageUpdate)
					{
						if (messages.unread > 0)
						{
							var newMessagesMessage:String = messages.unseen == 1 ? ResourceManager.getInstance().getString("resources", "notification.newMessage") : ResourceManager.getInstance().getString("resources", "notification.newMessages");
							log.info("Notification update! - {0}", newMessagesMessage);
							
							// show notification
							var newMessagesNotification:Notification = new Notification();
							newMessagesNotification.title = newMessagesMessage;
							newMessagesNotification.image = FacebookDesktopConst.FACEBOOK_MESSAGES_ICON;
							newMessagesNotification.link = FacebookDesktopConst.FACEBOOK_MESSAGES_URL;
							newMessagesNotification.isCompact = true;
							newMessagesNotification.isSticky = model.preferences.showMessagesSticky;
							model.notificationManager.showNotification(newMessagesNotification);
						}  // if statement
						
						// update model
						log.info("Setting latest message update time to " + messages.most_recent);
						model.latestMessageUpdate = messages.most_recent;
					}  // if statement
					
					// pokes
					var pokes:Object = result.pokes;
					if (model.preferences.showPokes && pokes != null && pokes.most_recent > model.latestPokeUpdate)
					{
						if (pokes.unread > 0)
						{
							var newPokeMessage:String = ResourceManager.getInstance().getString("resources", "notification.poked");
							log.info("Notification update! - {0}", newPokeMessage);
							
							// show notification
							var pokeNotification:Notification = new Notification();
							pokeNotification.title = newPokeMessage;
							pokeNotification.image = FacebookDesktopConst.FACEBOOK_POKES_ICON;
							pokeNotification.link = FacebookDesktopConst.FACEBOOK_POKES_URL;
							pokeNotification.isCompact = true;
							pokeNotification.isSticky = model.preferences.showPokesSticky;
							model.notificationManager.showNotification(pokeNotification);
						}  // if statement
						
						// update model
						log.info("Setting latest poke update time to " + pokes.most_recent);
						model.latestPokeUpdate = pokes.most_recent;
					}  // if statement
					
					// shares
					var shares:Object = result.shares;
					if (model.preferences.showShares && shares != null && shares.most_recent > model.latestShareUpdate)
					{
						if (shares.unread > 0)
						{
							var newShareMessage:String = ResourceManager.getInstance().getString("resources", "notification.poked");
							log.info("Notification update! - {0}", newShareMessage);
							
							// show notification
							var shareNotification:Notification = new Notification();
							shareNotification.title = newShareMessage;
							shareNotification.image = FacebookDesktopConst.FACEBOOK_SHARES_ICON;
							shareNotification.link = FacebookDesktopConst.FACEBOOK_SHARES_URL;
							shareNotification.isCompact = true;
							shareNotification.isSticky = model.preferences.showSharesSticky;
							model.notificationManager.showNotification(shareNotification);
						}  // if statement
						
						// update model
						log.info("Setting latest share update time to " + shares.most_recent);
						model.latestShareUpdate = shares.most_recent;
					}  // if statement
					
					systemInteractionManager.addAdditionalNotificationsToMenu(result);
				}  // if statement
				else if (result != null && result.error_code != null)
				{
					log.error("Request to get latest additional notifications has failed!  Error object: " + ObjectUtil.toString(result));
				}  // else-if statement
				else if (fail != null)
				{
					log.error("Request to get latest additional notifications has failed!  Error object: " + ObjectUtil.toString(fail));
				}  // else statement
				
				// make sure we call the callback
				if (callback != null && callback is Function)
				{
					callback(result, fail, passThroughArgs);
				}  // if statement
			}  // getAdditionalNotificationsHandler
		}  // execute
	}  // class declaration
}  // package