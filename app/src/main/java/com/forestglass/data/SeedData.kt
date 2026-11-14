package com.forestglass.data

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

suspend fun seedData(dao: LessonDao) = withContext(Dispatchers.IO) {
    if (dao.countLessons() > 0) return@withContext
    val lessons = listOf(
        Lesson("c1_l1", "الحركة في بعد واحد", 1, "dQw4w9WgXcQ", 45, 9),
        Lesson("c1_l2", "الحركة في بعدين", 1, "dQw4w9WgXcQ", 40, 7),
        Lesson("c2_l1", "قوانين نيوتن للحركة", 2, "dQw4w9WgXcQ", 50, 10),
        Lesson("c2_l2", "تطبيقات قوانين نيوتن", 2, "dQw4w9WgXcQ", 35, 8),
        Lesson("c3_l1", "الشغل والطاقة", 3, "dQw4w9WgXcQ", 40, 9),
        Lesson("c3_l2", "حفظ الطاقة الميكانيكية", 3, "dQw4w9WgXcQ", 45, 10),
        Lesson("c4_l1", "كمية التحرك والتصادمات", 4, "dQw4w9WgXcQ", 50, 8),
        Lesson("c5_l1", "الحركة الدورانية", 5, "dQw4w9WgXcQ", 55, 7),
        Lesson("c6_l1", "المرونة وتوازن الأجسام", 6, "dQw4w9WgXcQ", 40, 6),
        Lesson("c7_l1", "الموائع الساكنة", 7, "dQw4w9WgXcQ", 45, 8),
        Lesson("c8_l1", "الموائع المتحركة", 8, "dQw4w9WgXcQ", 50, 9)
    )
    val laws = listOf(
        PhysicsLaw("l1", "قانون نيوتن الأول", "F = 0", 2, "الجسم الساكن يبقى ساكنًا"),
        PhysicsLaw("l2", "قانون نيوتن الثاني", "F = m·a", 2, "القوة تساوي الكتلة × التسارع"),
        PhysicsLaw("l3", "قانون نيوتن الثالث", "F1 = -F2", 2, "لكل فعل رد فعل مساوٍ ومعاكس"),
        PhysicsLaw("l4", "معادلة الحركة الأولى", "v = u + a·t", 1, "السرعة النهائية بدلالة الزمن"),
        PhysicsLaw("l5", "قانون الشغل", "W = F·d·cos(θ)", 3, "الشغل = القوة × الإزاحة"),
        PhysicsLaw("l6", "الطاقة الحركية", "KE = ½·m·v²", 3, "طاقة الجسم المتحرك"),
        PhysicsLaw("l7", "كمية التحرك", "p = m·v", 4, "حاصل ضرب الكتلة بالسرعة"),
        PhysicsLaw("l8", "قانون أرخميدس", "F_b = ρ·V·g", 7, "قوة الطفو في الموائع")
    )
    dao.insertLessons(lessons)
    dao.insertLaws(laws)
}
