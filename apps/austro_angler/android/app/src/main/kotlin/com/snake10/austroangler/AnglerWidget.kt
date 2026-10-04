package com.snake10.austroangler

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/** Startbildschirm-Widget: Beißzeit und Wetter am Heimatort. */
class AnglerWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.angler_widget).apply {
                setTextViewText(R.id.widget_titel, widgetData.getString("titel", "🎣 Austro Angler"))
                setTextViewText(R.id.widget_text, widgetData.getString("text", "App öffnen, um Beißzeit und Wetter zu laden."))
                setOnClickPendingIntent(
                    R.id.widget_wurzel,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
