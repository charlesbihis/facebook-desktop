package com.facebook.desktop.control.api
{
	import com.facebook.desktop.control.notification.ToastManager;
	import com.facebook.desktop.model.Model;
	import com.facebook.graph.FacebookDesktop;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.resources.ResourceManager;

	public class GetStartupNotifications
	{
		private static const API_CALL:String = "notifications.get";
		
		private static var model:Model = Model.instance;
		private static var logger:ILogger = Log.getLogger("com.facebook.desktop.control.api.GetStartupNotifications");
		
		public function execute(callback:Function = null):void
		{
			FacebookDesktop.callRestAPI(API_CALL, handler);
			
			function handler(notifications:Object, fail:Object):void
			{
				if (notifications)
				{
					// check messages
					if (model.preferences.showMessages && notifications.messages && notifications.messages.most_recent > model.latestMessageUpdate && notifications.messages.unread > 0)
					{
						var youHaveMessagesMessage:String;
						if (notifications.messages.unread > 1)
						{
							youHaveMessagesMessage = ResourceManager.getInstance().getString("resources", "notification.unreadMessagesBegin") + " " + notifications.messages.unread + " " + ResourceManager.getInstance().getString("resources", "notification.unreadMessagesEnd");
						}
						else
						{
							youHaveMessagesMessage = ResourceManager.getInstance().getString("resources", "notification.unreadMessage");
						}  // if statement
						
						logger.info("Notification update! - {0}", youHaveMessagesMessage);
						ToastManager.queueToast(youHaveMessagesMessage, "", "http://www.facebook.com/?sk=inbox", "/assets/images/toast/messages.png", true);
						model.latestMessageUpdate = notifications.messages.most_recent;
					}  // if statement
					
					// check pokes
					if (model.preferences.showPokes && notifications.pokes && notifications.pokes.most_recent > model.latestPokeUpdate && notifications.pokes.unread > 0)
					{
						logger.info("Notification update! - You have been poked!");
						ToastManager.queueToast(ResourceManager.getInstance().getString("resources", "notification.poked"), "", "http://www.facebook.com/", "/assets/images/toast/poke.png", true);
						model.latestPokeUpdate = notifications.pokes.most_recent;
					}  // if statement
					
					// check shares
					if (model.preferences.showShares && notifications.shares && notifications.shares.most_recent > model.latestShareUpdate && notifications.shares.unread > 0)
					{
						logger.info("Notification update! - Someone has shared a link with you");
						ToastManager.queueToast(ResourceManager.getInstance().getString("resources", "notification.sharedLink"), "", "http://www.facebook.com/notifications.php", "/assets/images/toast/link.png", true);
						model.latestShareUpdate = notifications.shares.most_recent;
					}  // if statement
					
					ToastManager.showAll();
				}
				else
				{
					logger.error("Error fetching notifications!  Error object: " + fail);
				}
				
				if (callback != null)
				{
					callback(notifications, fail);
				}  // if statement
			}  // handler
		}  // execute
	}  // class declaration
}  // package