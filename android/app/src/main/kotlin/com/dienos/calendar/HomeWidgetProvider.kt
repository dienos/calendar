package com.dienos.calendar

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.res.Configuration
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.GradientDrawable
import android.net.Uri
import android.os.Build
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider as HomeWidgetBaseProvider
import java.time.DayOfWeek
import java.time.LocalDate

class HomeWidgetProvider : HomeWidgetBaseProvider() {

    private val cellIds = intArrayOf(
        R.id.cell_0, R.id.cell_1, R.id.cell_2,
        R.id.cell_3, R.id.cell_4, R.id.cell_5, R.id.cell_6
    )
    private val dayLabelIds = intArrayOf(
        R.id.day_label_0, R.id.day_label_1, R.id.day_label_2,
        R.id.day_label_3, R.id.day_label_4, R.id.day_label_5, R.id.day_label_6
    )
    private val dayNumIds = intArrayOf(
        R.id.day_num_0, R.id.day_num_1, R.id.day_num_2,
        R.id.day_num_3, R.id.day_num_4, R.id.day_num_5, R.id.day_num_6
    )
    private val emotionIds = intArrayOf(
        R.id.emotion_0, R.id.emotion_1, R.id.emotion_2,
        R.id.emotion_3, R.id.emotion_4, R.id.emotion_5, R.id.emotion_6
    )

    private val dayLabels = arrayOf("월", "화", "수", "목", "금", "토", "일")

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val sharedPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        val themeName = sharedPrefs.getString("flutter.theme_name", "warmPink") ?: "warmPink"
        val themeMode = sharedPrefs.getString("flutter.theme_mode", "system") ?: "system"
        val isDark = resolveIsDark(context, themeMode)

        val gradientColors = ThemeColors.getGradientColors(themeName, isDark)
        val textColor = ThemeColors.getTextColor(isDark)
        val subTextColor = ThemeColors.getSubTextColor(isDark)
        val todayBgColor = ThemeColors.getTodayBgColor(themeName, isDark)

        val today = LocalDate.now()
        val weekStart = today.minusDays(6)

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.home_widget_layout)

            applyGradientBackground(views, gradientColors)

            for (i in 0..6) {
                val date = weekStart.plusDays(i.toLong())
                val dateStr = "${date.year}-${date.monthValue.toString().padStart(2, '0')}-${date.dayOfMonth.toString().padStart(2, '0')}"
                val isToday = date == today

                // 요일 라벨 동적 계산 (월, 화, 수, 목, 금, 토, 일)
                val dayLabel = when (date.dayOfWeek) {
                    DayOfWeek.MONDAY -> "월"
                    DayOfWeek.TUESDAY -> "화"
                    DayOfWeek.WEDNESDAY -> "수"
                    DayOfWeek.THURSDAY -> "목"
                    DayOfWeek.FRIDAY -> "금"
                    DayOfWeek.SATURDAY -> "토"
                    DayOfWeek.SUNDAY -> "일"
                }

                views.setTextViewText(dayLabelIds[i], dayLabel)
                views.setTextColor(dayLabelIds[i], subTextColor)
                views.setTextViewText(dayNumIds[i], date.dayOfMonth.toString())

                if (isToday) {
                    views.setInt(dayNumIds[i], "setBackgroundColor", todayBgColor)
                    views.setTextColor(dayNumIds[i], textColor)
                } else {
                    views.setInt(dayNumIds[i], "setBackgroundColor", 0x00000000)
                    views.setTextColor(dayNumIds[i], textColor)
                }

                val emotionLabel = widgetData.getString("emotion_$i", "") ?: ""
                val emotionResId = emotionLabelToDrawable(context, emotionLabel)
                if (emotionResId != 0) {
                    views.setImageViewResource(emotionIds[i], emotionResId)
                } else {
                    views.setImageViewResource(emotionIds[i], R.drawable.emotion_empty)
                }

                val uri = Uri.parse("dienos://widget?date=$dateStr")
                val intent = Intent(context, MainActivity::class.java).apply {
                    action = "es.antonborri.home_widget.action.LAUNCH"
                    data = uri
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S)
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
                else PendingIntent.FLAG_UPDATE_CURRENT
                val pendingIntent = PendingIntent.getActivity(context, i, intent, flags)
                views.setOnClickPendingIntent(cellIds[i], pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun resolveIsDark(context: Context, themeMode: String): Boolean {
        return when (themeMode) {
            "dark" -> true
            "light" -> false
            else -> {
                val nightModeFlags = context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
                nightModeFlags == Configuration.UI_MODE_NIGHT_YES
            }
        }
    }

    private fun applyGradientBackground(views: RemoteViews, colors: IntArray) {
        val gradient = GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM, colors)
        gradient.cornerRadius = 24f
        val bitmap = Bitmap.createBitmap(400, 100, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        gradient.setBounds(0, 0, canvas.width, canvas.height)
        gradient.draw(canvas)
        views.setImageViewBitmap(R.id.widget_background, bitmap)
    }

    private fun emotionLabelToDrawable(context: Context, label: String): Int {
        val resName = when (label) {
            "정말 좋음", "very_good" -> "emotion_very_good"
            "좋음", "good" -> "emotion_good"
            "보통", "soso" -> "emotion_soso"
            "나쁨", "bad" -> "emotion_bad"
            "끔찍함", "very_bad" -> "emotion_very_bad"
            else -> return 0
        }
        return context.resources.getIdentifier(resName, "drawable", context.packageName)
    }
}
