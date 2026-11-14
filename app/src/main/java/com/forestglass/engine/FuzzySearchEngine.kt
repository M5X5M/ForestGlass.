package com.forestglass.engine

import com.forestglass.data.PhysicsLaw

object FuzzySearchEngine {
    fun search(query: String, laws: List<PhysicsLaw>, threshold: Double = 0.55): List<PhysicsLaw> {
        if (query.isBlank()) return emptyList()
        val nq = normalize(query)
        return laws.map { law ->
            val best = maxOf(
                similarity(nq, normalize(law.title)),
                similarity(nq, normalize(law.formula)),
                similarity(nq, normalize(law.description))
            )
            law to best
        }.filter { it.second >= threshold }
            .sortedByDescending { it.second }
            .map { it.first }
    }
    private fun normalize(s: String): String =
        s.trim().lowercase()
            .replace("أ", "ا").replace("إ", "ا").replace("آ", "ا")
            .replace("ة", "ه").replace("ى", "ي")
            .replace(Regex("[\\u064B-\\u065F]"), "")
    private fun similarity(a: String, b: String): Double {
        if (a == b) return 1.0
        if (a.isEmpty() || b.isEmpty()) return 0.0
        return 1.0 - levenshtein(a, b).toDouble() / maxOf(a.length, b.length)
    }
    private fun levenshtein(a: String, b: String): Int {
        val dp = Array(a.length + 1) { IntArray(b.length + 1) }
        for (i in 0..a.length) dp[i][0] = i
        for (j in 0..b.length) dp[0][j] = j
        for (i in 1..a.length) for (j in 1..b.length) {
            val cost = if (a[i - 1] == b[j - 1]) 0 else 1
            dp[i][j] = minOf(dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost)
        }
        return dp[a.length][b.length]
    }
}
