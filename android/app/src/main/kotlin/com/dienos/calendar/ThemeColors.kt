package com.dienos.calendar

object ThemeColors {
    private val gradients = mapOf(
        "warmPink" to mapOf(
            "light" to intArrayOf(0xFFFDE8EC.toInt(), 0xFFFDF0F2.toInt(), 0xFFFFF6F7.toInt(), 0xFFFFFBFB.toInt()),
            "dark" to intArrayOf(0xFF1A090C.toInt(), 0xFF2C0E14.toInt(), 0xFF3D1421.toInt(), 0xFF4A192C.toInt())
        ),
        "softLemon" to mapOf(
            "light" to intArrayOf(0xFFFFFDE7.toInt(), 0xFFFFF9C4.toInt(), 0xFFFFF59D.toInt(), 0xFFFFF176.toInt()),
            "dark" to intArrayOf(0xFF1F1412.toInt(), 0xFF2D1D1A.toInt(), 0xFF3E2723.toInt(), 0xFF5D4037.toInt())
        ),
        "skyBlue" to mapOf(
            "light" to intArrayOf(0xFFE3F2FD.toInt(), 0xFFBBDEFB.toInt(), 0xFF90CAF9.toInt(), 0xFF64B5F6.toInt()),
            "dark" to intArrayOf(0xFF051F42.toInt(), 0xFF0D2D5E.toInt(), 0xFF0D47A1.toInt(), 0xFF1976D2.toInt())
        ),
        "mintGreen" to mapOf(
            "light" to intArrayOf(0xFFE8F5E9.toInt(), 0xFFC8E6C9.toInt(), 0xFFA5D6A7.toInt(), 0xFF81C784.toInt()),
            "dark" to intArrayOf(0xFF0A240C.toInt(), 0xFF123116.toInt(), 0xFF1B5E20.toInt(), 0xFF388E3C.toInt())
        ),
        "lavender" to mapOf(
            "light" to intArrayOf(0xFFF3E5F5.toInt(), 0xFFE1BEE7.toInt(), 0xFFCE93D8.toInt(), 0xFFBA68C8.toInt()),
            "dark" to intArrayOf(0xFF140B3D.toInt(), 0xFF211261.toInt(), 0xFF311B92.toInt(), 0xFF512DA8.toInt())
        ),
        "creamyWhite" to mapOf(
            "light" to intArrayOf(0xFFFAFAFA.toInt(), 0xFFF5F5F5.toInt(), 0xFFEEEEEE.toInt(), 0xFFE0E0E0.toInt()),
            "dark" to intArrayOf(0xFF000000.toInt(), 0xFF121212.toInt(), 0xFF1E1E1E.toInt(), 0xFF212121.toInt())
        )
    )

    fun getGradientColors(themeName: String, isDark: Boolean): IntArray {
        val key = if (isDark) "dark" else "light"
        return gradients[themeName]?.get(key) ?: gradients["warmPink"]!!["light"]!!
    }

    fun getTextColor(isDark: Boolean): Int {
        return if (isDark) 0xFFFFFFFF.toInt() else 0xFF333333.toInt()
    }

    fun getSubTextColor(isDark: Boolean): Int {
        return if (isDark) 0xAAFFFFFF.toInt() else 0x88000000.toInt()
    }

    fun getTodayBgColor(themeName: String, isDark: Boolean): Int {
        return if (isDark) 0x44FFFFFF.toInt() else 0x33000000.toInt()
    }
}
