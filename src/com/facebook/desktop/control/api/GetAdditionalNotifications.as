package com.facebook.desktop.control.api
{
	import com.facebook.desktop.control.notification.ToastManager;
	import com.facebook.desktop.control.system.SystemIcons;
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
					
					// friend requests
					
					// group invites
					
					// messages
					var messages:Object = result.messages;	// TODO: add control for this in preferences
					if (true && messages != null && messages.most_recent > model.latestMessageUpdate)
					{
						// add unread count to context menu
						SystemIcons.addAdditionalNotificationsToMenu(messages.unread);
						
						// show notification only for unseen messages
						if (messages.unseen > 0)
						{
							var newMessagesMessage:String = messages.unseen > 1 ? ResourceManager.getInstance().getString("resources", "notification.newMessages") : ResourceManager.getInstance().getString("resources", "notification.newMessage");
							log.info("Notification update! - {0}", newMessagesMessage);
							ToastManager.queueToast(newMessagesMessage, "", "http://www.facebook.com/?sk=inbox", "/assets/images/toast/messages.png", true);
						}  // if statement
						
						// if this is our first application call, display a summary notification for unread messages
						if (isStartup)
						{
							var startupUnreadMessagesMessage:String = (messages.unread == 1 ? ResourceManager.getInstance().getString("resources", "notification.unreadMessage") : ResourceManager.getInstance().getString("resources", "notification.unreadMessagesBegin") + " " + messages.unread + " " + ResourceManager.getInstance().getString("resources", "notification.unreadMessagesEnd"));
							log.info("Startup notification! - {0}", startupUnreadMessagesMessage);
							ToastManager.queueToast(startupUnreadMessagesMessage, "", "http://www.facebook.com/?sk=inbox", "/assets/images/toast/messages.png", true);
						}  // if statement
					}  // if statement
					
					// pokes
					
					// shares
					ToastManager.showAll();
				}  // if statement
				else
				{
					log.error("Request to get latest additional notifications has failed!  Error object: " + ObjectUtil.toString(fail));
				}  // else statement
			}  // getAdditionalNotificationsHandler
		}  // execute
	}  // class declaration
}  // package