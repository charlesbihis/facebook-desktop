package com.facebook.desktop.control.api
{
	import com.facebook.desktop.model.Model;
	import com.facebook.graph.FacebookDesktop;
	import com.facebook.desktop.control.notification.ToastManager;
	
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class GetProfileNotifications
	{
		private static const API_CALL:String = "notifications.get";
		
		private static var model:Model = Model.instance;
		private static var logger:ILogger = Log.getLogger("com.facebook.desktop.control.api.GetProfileNotifications");
		
		public function execute(callback:Function = null):void
		{
			FacebookDesktop.callRestAPI(API_CALL, handler);
			
			function handler(notifications:Object, fail:Object):void
			{
				if (notifications)
				{
					// check friend requests
					if (model.preferences.showFriendRequests && notifications.friend_requests && (notifications.friend_requests is Array) && notifications.friend_requests.length > 0)
					{
						var youHaveFriendRequestsMessage:String = "You have " + notifications.friend_requests.length + " friend request" + ((notifications.friend_requests.length > 1) ? "s" : "");
						logger.info("Profile update!  - {0}", youHaveFriendRequestsMessage);
						ToastManager.queueToast(youHaveFriendRequestsMessage, "", "http://www.facebook.com/reqs.php", "/assets/images/toast/friend-request.png", true);
					}  // if statement
					
					// check group invites
					if (model.preferences.showGroupInvites && notifications.group_invites && (notifications.group_invites is Array) && notifications.group_invites.length > 0)
					{
						var youHaveGroupInvitesMessage:String = "You have " + notifications.group_invites.length + " group invitation";
						if (notifications.group_invites.length > 1)
						{
							youHaveGroupInvitesMessage += "s";
						}  // if statement
						logger.info("Profile update!  - {0}", youHaveGroupInvitesMessage);
						ToastManager.queueToast(youHaveGroupInvitesMessage, "", "http://www.facebook.com/?sk=2361831622", "/assets/images/toast/groups.png", true);
					}  // if statement
					
					// event invites
					if (model.preferences.showEventInvites && notifications.event_invites && (notifications.event_invites is Array) && notifications.event_invites.length > 0)
					{
						var youHaveEventRequestMessage:String = "You have " + notifications.event_invites.length + " event invitation" + ((notifications.event_invites.length > 1) ? "s" : "");
						logger.info("Profile update!  - {0}", youHaveEventRequestMessage);
						ToastManager.queueToast(youHaveEventRequestMessage, "", "http://www.facebook.com/?sk=events", "/assets/images/toast/events.png", true);
					}  // if statement
					
					ToastManager.showAll();
				}  // if statement
				else
				{
					logger.error("Error fetching notifications!  Error: " + fail);
				}  // else statement
				
				if (callback != null)
				{
					callback(notifications, fail);
				}  // if statement
			}  // handler
		}  // execute
	}  // class declaration
}  // package