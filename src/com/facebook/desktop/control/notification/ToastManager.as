package com.facebook.desktop.control.notification
{
	import com.facebook.desktop.model.Model;
	import com.facebook.desktop.view.Toast;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.resources.ResourceManager;

	public class ToastManager
	{
		public static const DISPLAY_TIME:int = 7000;
		public static const CLOSE_BUFFER:int = 1000;
		
		private static const DEFAULT_ICON:String = "/assets/images/toast/icon50.png";
		
		private static var toastQueue:ArrayCollection = new ArrayCollection();
		private static var timer:Timer = new Timer(1000);
		private static var playing:Boolean = true;
		private static var overloaded:Boolean;
		private static var summaryToast:Toast = null;
		private static var model:Model = Model.instance;
		private static var logger:ILogger = Log.getLogger("com.facebook.desktop.control.notification.ToastManager");
		
		public static function show(title:String, message:String, link:String = null, image:String = DEFAULT_ICON, isNotification:Boolean = false):void
		{
			var toast:Toast = new Toast();
			toast.toastImage = image;
			toast.toastTitle = title;
			toast.toastMessage = message;
			toast.toastLink = link;
			toast.toastIsNotification = isNotification;
			toast.alwaysInFront = true;
			
			showToast(toast);
		}  // show
		
		public static function pauseExpiration():void
		{
			timer.stop();
			playing = false;
		}  // pauseExpiration
		
		public static function resumeExpiration():void
		{
			timer.start();
			playing = true;
			
			if (summaryToast != null)
			{
				logger.info("Displaying summary-toast with a queue of {0} messages", model.activeToasts.length);
				summaryToast.toastImage = DEFAULT_ICON;
				summaryToast.toastTitle = ResourceManager.getInstance().getString("resources", "toast.storyUpdates");
				summaryToast.toastMessage = ResourceManager.getInstance().getString("resources", "toast.summaryBegin") + " " + model.activeToasts.length + " " + ResourceManager.getInstance().getString("resources", "toast.summaryEnd");
//				summaryToast.toastLink = "http://www.facebook.com/";
				summaryToast.alwaysInFront = true;
				summaryToast.open(false);
				setTimeout(closeToast, DISPLAY_TIME + CLOSE_BUFFER);
				
				model.activeToasts.removeAll();
				overloaded = false;
				
				function closeToast():void
				{
					summaryToast.closeToast();
					summaryToast = null;
				}  // closeToast
			}  // if statement
		}  // resumeExpiration
		
		public static function queueToast(title:String, message:String, link:String = null, image:String = DEFAULT_ICON, isNotification:Boolean = false):void
		{
			var toast:Toast = new Toast();
			toast.toastImage = image;
			toast.toastTitle = title;
			toast.toastMessage = message;
			toast.toastLink = link;
			toast.toastIsNotification = isNotification;
			toast.alwaysInFront = true;
			
			toastQueue.addItem(toast);
		}  // queueToast
		
		public static function showAll():void
		{
			if (toastQueue.length <= 0)
			{
				return;
			}  // if statement
			
			var toast:Toast = Toast(toastQueue.getItemAt(0));
			toastQueue.removeItemAt(0);
			
			setTimeout(showThisToast, 500);
			function showThisToast():void
			{
				// show this single toast
				showToast(toast);
				
				// recursively call showAll() until all remaining toasts have been shown
				showAll();
			}  // showToast
		}  // showAll
		
		public static function showLatestFiveUpdates():void
		{
			if (model.latestFiveUpdates.length <= 0)
			{
				ToastManager.show(ResourceManager.getInstance().getString("resources", "toast.noUpdates"), "");
				
				return;
			}  // if statement
			
			var toast:Toast;
			for (var i:int = 0; i < model.latestFiveUpdates.length; i++)
			{
				toast = Toast(model.latestFiveUpdates.getItemAt(i));
				queueToast(toast.toastTitle, toast.toastMessage, toast.toastLink, toast.toastImage, toast.toastIsNotification);
			}  // for loop
			model.latestFiveUpdates.removeAll();
			
			showAll();
		}  // showLatestFiveUpdates
		
		private static function showToast(toast:Toast):void
		{
			// HACK: Detecting if the toast we are about the show is identical
			// to the toast we've just shown.  This fixes the duplicate toasts bug
			// that we have.  This is a hack because instead of doing this, we should
			// be instead finding out why showToast() or queueToast() is being called
			// more than once for the same toast.
			if (model.activeToasts.length > 0)
			{
				if (toast.equals(Toast(model.activeToasts.getItemAt(model.activeToasts.length - 1))))
				{
					logger.info("Just repressed the showing of a duplicate toast");
					return;
				}  // inner if statement
			}  // outer if statement
			
			if (!overloaded)
			{
				toast.open(false);
			}  // if statement
			else
			{
				logger.info("Putting toast in queue");
			}  // else statement
			
			timer.addEventListener(TimerEvent.TIMER, timeToTick);
			if (playing)
			{
				timer.start();
			}  // if statement
			
			// Add toast to active-toast list.  If we're displaying too many toasts
			// and the user is idling, then let's close all of the open ones
			// and display a summary toast when the user returns.
			model.activeToasts.addItem(toast);
			if (model.activeToasts.length > Model.MAX_ACTIVE_TOASTS && !playing)
			{
				overloaded = true;
				
				// close all the current ones
				for (var i:int = 0; i < model.activeToasts.length; i++)
				{
					model.activeToasts.getItemAt(i).closeToast();
				}  // for loop
				
				// create the summary toast
				if (summaryToast == null)
				{
					summaryToast = new Toast();
				}  // if statement
			}  // if statement
			
			// Finally, add this toast to the queue of recent toasts.  Only add if
			// it isn't a notification toast (i.e. it has a permalink) <- don't know if this logic will work, but will try for now
			if (toast.toastLink != null && toast.toastLink != "")
			{
				// let's filter particular toasts here
				if (toast.toastTitle != ResourceManager.getInstance().getString("resources", "toast.welcome"))
				{
					model.latestFiveUpdates.addItem(toast);
				}  // if statement
			}  // if statement
			
			while (model.latestFiveUpdates.length > 5)
			{
				model.latestFiveUpdates.removeItemAt(0);
			}  // while loop
			
			function timeToTick():void
			{
				if (toast.tick())
				{
					// Remove the toast (but check if we've already removed it first - could
					// have been removed if it was queued up while the user was idling)
					if (model.activeToasts.getItemIndex(toast) >= 0)
					{
						model.activeToasts.removeItemAt(model.activeToasts.getItemIndex(toast));
					}  // inner if statement
				}  // if statement
			}  // timeToTick
		}  // showToast
	}  // class declaration
}  // package