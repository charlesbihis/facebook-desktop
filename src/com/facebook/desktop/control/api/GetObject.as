package com.facebook.desktop.control.api
{
	import com.facebook.desktop.model.Model;
	import com.facebook.graph.FacebookDesktop;
	
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class GetObject
	{
		public var objectId:String;
		
		private static var logger:ILogger = Log.getLogger("com.facebook.desktop.control.api.GetObject");
		
		public function GetObject(objectId:String)
		{
			this.objectId = objectId;
		}  // GetObject
		
		public function execute(callback:Function = null):void
		{
			if (objectId)
			{
				FacebookDesktop.api(objectId, getObjectHandler, {include_read:true});
			}  // if statement
			else
			{
				throw new Error("Error fetching object.  Object ID is null.");
			}  // else statement
			
			function getObjectHandler(result:Object, fail:Object):void
			{
				if (callback)
				{
					callback(result);
				}  // if statement
			}  // getObjectHandler
		}  // execute
	}  // class declaration
}  // package