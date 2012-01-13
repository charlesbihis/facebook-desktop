package com.facebook.desktop.control.api
{
	import com.facebook.desktop.control.notification.ToastManager;
	import com.facebook.desktop.control.system.SystemIcons;
	import com.facebook.desktop.control.util.Util;
	import com.facebook.desktop.model.Model;
	import com.facebook.graph.FacebookDesktop;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.resources.ResourceManager;
	import mx.utils.ObjectUtil;

	public class GetAdditionalNotifications
	{
		private static const API:String = "notifications.get";
		
		private static var model:Model = Model.instance;
		private static var log:ILogger = Log.getLogger("com.facebook.desktop.control.api.GetAdditionalNotifications");
		
		public function GetAdditionalNotifications()
		{
			
		}
		
		public function execute(callback:Function = null, isStartup:Boolean = false):void
		{
			FacebookDesktop.callRestAPI(API, getAdditionalNotificationsHandler);
			
			function getAdditionalNotificationsHandler(result:Object, fail:Object):void
			{
				if (fail == null && result != null)
				{
					// event invites
					if (model.preferences.showEventInvites && result.event_invites != null && result.event_invites is Array && result.event_invites.length > 0)
					{
						// if this is our first application call, display a summary notification
						if (isStartup)
						{
							var startupEventInvitesMessage:String = (result.event_invites.length == 1 ? ResourceManager.getInstance().getString("resources", "notification.eventInvitation") : ResourceManager.getInstance().getString("resources", "notification.eventInvitationsBegin") + " " + result.event_invites.length + " " + ResourceManager.getInstance().getString("resources", "notification.eventInvitationsEnd"));
							log.info("Startup notification! - {0}", startupEventInvitesMessage);
							ToastManager.queueToast(startupEventInvitesMessage, "", "http://www.facebook.com/events/", "/assets/images/toast/events.png", true);
						}  // if statement
					}  // if statement
					
					// friend requests
					if (model.preferences.showFriendRequests && result.friend_requests != null && result.friend_requests is Array && result.friend_requests.length > 0)
					{
						// if this is our first application call, display a summary notification
						if (isStartup)
						{
							var startupFriendRequestsMessage:String = (result.friend_requests.length == 1 ? ResourceManager.getInstance().getString("resources", "notification.friendRequest") : ResourceManager.getInstance().getString("resources", "notification.friendRequestsBegin") + " " + result.event_invites.length + " " + ResourceManager.getInstance().getString("resources", "notification.friendRequestsEnd"));
							log.info("Startup notification! - {0}", startupFriendRequestsMessage);
							ToastManager.queueToast(startupFriendRequestsMessage, "", "http://www.facebook.com/friends/edit/?sk=requests", "/assets/images/toast/friend-request.png", true);
						}  // if statement
					}  // if statement
					
					// group invites
					if (model.preferences.showGroupInvites && result.group_invites != null && result.group_invites is Array && result.group_invites.length > 0)
					{
						// if this is our first application call, display a summary notification
						if (isStartup)
						{
							var startupGroupInvitesMessage:String = (result.group_invites.length == 1 ? ResourceManager.getInstance().getString("resources", "notification.groupInvitation") : ResourceManager.getInstance().getString("resources", "notification.groupInvitationsBegin") + " " + result.group_invites.length + " " + ResourceManager.getInstance().getString("resources", "notification.groupInvitationsEnd"));
							log.info("Startup notification! - {0}", startupGroupInvitesMessage);
							ToastManager.queueToast(startupGroupInvitesMessage, "", "http://www.facebook.com/bookmarks/groups/", "/assets/images/toast/groups.png", true);
						}  // if statement
					}  // if statement
					
					// messages
					var messages:Object = result.messages;
					if (model.preferences.showMessages && messages != null && messages.most_recent > model.latestMessageUpdate)
					{
						// show notification
						if (messages.unread > 0)
						{
							var newMessagesMessage:String = messages.unseen == 1 ? ResourceManager.getInstance().getString("resources", "notification.newMessage") : ResourceManager.getInstance().getString("resources", "notification.newMessages");
							log.info("Notification update! - {0}", newMessagesMessage);
							ToastManager.queueToast(newMessagesMessage, "", "http://www.facebook.com/messages/", "/assets/images/toast/messages.png", true);
						}  // if statement
						
						// update model
						log.info("Setting latest message update time to " + messages.most_recent);
						model.latestMessageUpdate = messages.most_recent;
					}  // if statement
					
					// pokes
					var pokes:Object = result.pokes;
					if (model.preferences.showPokes && pokes != null && pokes.most_recent > model.latestPokeUpdate)
					{
						// show notification
						if (pokes.unread > 0)
						{
							var newPokeMessage:String = ResourceManager.getInstance().getString("resources", "notification.poked");
							log.info("Notification update! - {0}", newPokeMessage);
							ToastManager.queueToast(newPokeMessage, "", "http://www.facebook.com/notifications/", "/assets/images/toast/poke.png", true);
						}  // if statement
						
						// update model
						log.info("Setting latest poke update time to " + pokes.most_recent);
						model.latestPokeUpdate = pokes.most_recent;
					}  // if statement
					
					// shares
					var shares:Object = result.pokes;
					if (model.preferences.showShares && pokes != null && shares.most_recent > model.latestShareUpdate)
					{
						// show notification
						if (shares.unread > 0)
						{
							var newShareMessage:String = ResourceManager.getInstance().getString("resources", "notification.poked");
							log.info("Notification update! - {0}", newShareMessage);
							ToastManager.queueToast(newShareMessage, "", "http://www.facebook.com/notifications/", "/assets/images/toast/link.png", true);
						}  // if statement
						
						// update model
						log.info("Setting latest share update time to " + shares.most_recent);
						model.latestShareUpdate = shares.most_recent;
					}  // if statement
					
					SystemIcons.addAdditionalNotificationsToMenu(result);
					
					ToastManager.showAll();
				}  // if statement
				else if (fail != null)
				{
					log.error("Request to get latest additional notifications has failed!  Error object: " + ObjectUtil.toString(fail));
				}  // else statement
			}  // getAdditionalNotificationsHandler
		}  // execute
	}  // class declaration
}  // package