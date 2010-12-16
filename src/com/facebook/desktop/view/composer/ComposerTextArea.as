package com.facebook.desktop.view.composer
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.events.FlexEvent;
	import mx.managers.FocusManager;
	import mx.utils.StringUtil;
	
	import spark.components.TextArea;
	
	public class ComposerTextArea extends TextArea
	{
		private static const SHADOW_TEXT:String = "What's on your mind?";
		private static const ENABLED_TEXT_COLOR:uint = 0x333333;
		private static const DISABLED_TEXT_COLOR:uint = 0x808080;
		
		private var _active:Boolean = true;
		
		public function ComposerTextArea()
		{
			super();
			
			text = SHADOW_TEXT;
			
			addEventListener(FocusEvent.FOCUS_IN, focusIn);
			addEventListener(FocusEvent.FOCUS_OUT, focusOut);
			addEventListener(FlexEvent.CREATION_COMPLETE, creationComplete);
			
			function focusIn(event:FocusEvent):void
			{
				active = true;
				
				if (text == SHADOW_TEXT)
				{
					text = "";
				}  // if statement
			}  // focusIn
			
			function focusOut(event:FocusEvent):void
			{
				active = false;
			}  // focusOut
		}  // GrowableTextArea
		
		[Bindable]
		public function get active():Boolean
		{
			return _active;
		}  // active
		
		public function set active(active:Boolean):void
		{
			_active = active;
			updateState();
		}  // active
		
		private function creationComplete(event:Event):void
		{
			updateState();
		}  // creationComplete
		
		private function updateState():void
		{
			setStyle("color", active ? ENABLED_TEXT_COLOR : DISABLED_TEXT_COLOR);
			
			if (!active && mx.utils.StringUtil.trim(text).length == 0)
			{
				text = SHADOW_TEXT;
			}  // if statement
		}  // updateState
	}  // class declaration
}  // package