package com.facebook.desktop.control.api
{
	import com.facebook.desktop.view.window.MessageWindow;
	import com.facebook.graph.FacebookDesktop;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.resources.ResourceManager;
	import mx.utils.ObjectUtil;

	public class UpdateStatus
	{
		private static var log:ILogger = Log.getLogger("com.facebook.desktop.control.api.UpdateStatus");
		
		public function execute(args:Object = null, callback:Function = null, passThroughArgs:Object = null):void
		{
			FacebookDesktop.api("/me/feed", handler, args, "POST");
			
			function handler(result:Object, fail:Object):void
			{
				if (fail == null)
				{
					log.info("Status update successful, published with id: " + result.id);
				}  // if statement
				else
				{
					log.error("Error updating status!  Error object: " + ObjectUtil.toString(fail));
					
					var messageWindow:MessageWindow = new MessageWindow();
					messageWindow.windowTitle = ResourceManager.getInstance().getString("resources", "action.error");
					messageWindow.showOkayButton = true;
					messageWindow.windowMessage = ResourceManager.getInstance().getString("resources", "action.statusUpdate.error");
					messageWindow.open();
				}  // else statement
				
				// make sure we call the callback
				if (callback != null && callback is Function)
				{
					callback(result, fail, passThroughArgs);
				}  // if statement
			}  // handler
		}  // execute
	}  // class declaration
}  // package