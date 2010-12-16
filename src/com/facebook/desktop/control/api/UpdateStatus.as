package com.facebook.desktop.control.api
{
	import com.facebook.desktop.view.window.MessageWindow;
	import com.facebook.graph.FacebookDesktop;
	
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class UpdateStatus
	{
		private static var logger:ILogger = Log.getLogger("com.facebook.desktop.control.api.UpdateStatus");
		
		public var message:String;
		
		public function execute(callback:Function = null):void
		{
			logger.info("Updating status: '" + message + "'");
			
			FacebookDesktop.api("/me/feed", handler, {message: message}, "POST");
			
			function handler(result:Object, fail:Object):void
			{
				if (!fail)
				{
					logger.info("Status update successful, published with id: " + result.id);
				}  // if statement
				else
				{
					logger.error("Error updating status!  Error: " + fail);
					
					var messageWindow:MessageWindow = new MessageWindow();
					messageWindow.windowTitle = "Error";
					messageWindow.showOkayButton = true;
					messageWindow.windowMessage = "There was an error updating your status.  Please try again later.";
					messageWindow.open();
				}  // else statement
				
				if (callback != null)
				{
					callback(result, fail);
				}  // if statement
			}  // handler
		}  // execute
	}  // class declaration
}  // package