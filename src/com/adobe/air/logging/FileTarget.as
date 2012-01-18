package com.adobe.air.logging
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.core.mx_internal;
	import mx.logging.targets.LineFormattedTarget;
	
	use namespace mx_internal;
	
	/**
	 * An AIR-only class that provides a log target for the Flex logging
	 * framework that logs files to a file on the user's system.
	 *
	 * This class will only work when running within Adobe AIR
	 */
	public class FileTarget extends LineFormattedTarget
	{
		private const DEFAULT_LOG_PATH:String = "app-storage:/application.log";
		
		private var log:File;
		
		public function FileTarget(logFile:File = null)
		{
			if (logFile != null)
			{
				log = logFile;
			}  // if statement
			else
			{
				log = new File(DEFAULT_LOG_PATH);
			}  // else statement
		}  // FileTarget
		
		public function get logURI():String
		{
			return log.url;
		}  // logURI
		
		mx_internal override function internalLog(message:String):void
		{
			write(message);
		}  // internalLog
		
		private function write(message:String):void
		{
			var fileStream:FileStream = new FileStream();
			fileStream.open(log, FileMode.APPEND);
			fileStream.writeUTFBytes(message + File.lineEnding);
			fileStream.close();
			
			trace(message);
		}  // write
		
		public function clear():void
		{
			var fileStream:FileStream = new FileStream();
			fileStream.open(log, FileMode.WRITE);
			fileStream.writeUTFBytes("");
			fileStream.close();
		}  // clear
	}  // class declaration
}  // package
