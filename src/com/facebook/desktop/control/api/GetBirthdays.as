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
	import mx.utils.ObjectUtil;

	public class GetBirthdays implements ICommand
	{
		private static const API:String = "fql.query";
		
		private var model:Model = Model.instance;
		private var systemInteractionManager:SystemInteractionManager = SystemInteractionManager.instance;
		private var log:ILogger = Log.getLogger("com.facebook.desktop.control.api.GetBirthdays");
		
		public function execute(args:Object = null, callback:Function = null, passThroughArgs:Object = null):void
		{
			var today:Date = new Date();
			var thisMonthNumber:Number = today.month + 1;
			var thisMonthString:String = (thisMonthNumber <= 9) ? "0" + thisMonthNumber : thisMonthNumber + "";
			var thisDateString:String = (today.date <= 9) ? "0" + today.date : today.date + "";
			var birthdayString:String = thisMonthString + "/" + thisDateString;
			var fql:String = "SELECT name, uid, birthday_date FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) AND '" + birthdayString + "' IN birthday_date";
			
			if (model.preferences.showBirthdays && (model.latestBirthdayString != birthdayString || (passThroughArgs != null && (passThroughArgs.source == FacebookDesktopConst.STARTUP || passThroughArgs.source == FacebookDesktopConst.CONTEXT_MENU_CLICK))))
			{
				FacebookDesktop.callRestAPI(API, getBirthdaysHandler, {query:fql});
				model.latestBirthdayString = birthdayString;
			}  // if statement
			else if (!model.preferences.showBirthdays)
			{
				systemInteractionManager.addBirthdaysToMenu(null);
			}  // else-if statement
			
			function getBirthdaysHandler(result:Object, fail:Object):void
			{
				if (fail == null && result != null && result is Array)
				{
					var birthdays:Array = result as Array;
					for (var i:int = 0; i < birthdays.length; i++)
					{
						var birthdayNotification:Notification = new Notification();
						birthdayNotification.title = "It's " + birthdays[i].name + "'s birthday today!";
						birthdayNotification.image = FacebookDesktopConst.FACEBOOK_BIRTHDAY_ICON;
						birthdayNotification.link = FacebookDesktopConst.FACEBOOK_HOMEPAGE + birthdays[i].uid;
						birthdayNotification.isCompact = true;
						birthdayNotification.isSticky = model.preferences.showBirthdaysSticky;
						model.notificationManager.showNotification(birthdayNotification);
					}  // for loop
					
					systemInteractionManager.addBirthdaysToMenu(birthdays);
				}  // if statement
				else if (result != null && result.error_code != null)
				{
					log.error("Request to get friends birthdays has failed!  Error object: " + ObjectUtil.toString(result));
				}  // else-if statement
				else if (fail != null)
				{
					log.error("Request to get friends birthdays has failed!  Error object: " + ObjectUtil.toString(fail));
				}  // else statement
				
				// make sure we call the callback
				if (callback != null && callback is Function)
				{
					callback(result, fail, passThroughArgs);
				}  // if statement
			}  // getBirthdaysHandler
		}  // execute
	}  // class declaration
}  // package