package com.example.todo_mobile

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class TodoWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.todo_widget)

            // 获取待办数量
            val todoCount = widgetData.getInt("todo_count", 0)
            views.setTextViewText(R.id.widget_title, "今日待办 ($todoCount)")

            // 构建待办列表
            val stringBuilder = StringBuilder()
            for (i in 0 until minOf(todoCount, 5)) {
                val title = widgetData.getString("todo_${i}_title", "")
                val completed = widgetData.getBoolean("todo_${i}_completed", false)
                val status = if (completed) "✓" else "○"
                stringBuilder.append("$status $title\n")
            }

            if (todoCount == 0) {
                views.setTextViewText(R.id.widget_content, "今日暂无待办")
            } else {
                views.setTextViewText(R.id.widget_content, stringBuilder.toString())
            }

            // 设置点击事件（打开 App）
            val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            val pendingIntent = android.app.PendingIntent.getActivity(
                context, 0, intent,
                android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
