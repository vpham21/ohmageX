@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

	API =
		getSettingsDates: ->
			settings_dates = [
				{
					"campaign": "urn:campaign:ucla:runstrong:resources:nutrition:week1:withImages",
					"reminders": [
						{
							"survey_id": "slide1_2",
							"survey_title": "Slide C01 & 02",
							"message": "Eating enough calories during the day optimizes the effects of exercise training, among other benefits.",
							"day": 1,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide3_energyAvailabilityHandoutMessage",
							"survey_title": "Slide C03 & Energy Availability Handout",
							"message": "Inadequate calorie intake can lead to “low energy availability”, which is associated with several negative effects.",
							"day": 1,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide4_5_6",
							"survey_title": "Slide 04, 05 & 06",
							"message": "Effects of under-fueling include increased fatigue, prolong recovery, and loss of muscle mass, which may hinder performance.",
							"day": 2,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide7",
							"survey_title": "Slide 07",
							"message": "Under-fueling may also slow your metabolism, which lowers calorie burning during the day.",
							"day": 2,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide8",
							"survey_title": "Slide 08",
							"message": "Inadequate calorie intake alters other hormones that affect reproductive function and body composition.",
							"day": 3,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide9_10_11",
							"survey_title": "Slide C09, 10, & 11",
							"message": "Several effects of inadequate calorie intake reduce bone density & increase injury risk.",
							"day": 3,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide12_13",
							"survey_title": "Slide C12 & 13",
							"message": "Runners may develop inadequate energy intake if their exercise increases or food intake decreases- even if these changes are unintentional.",
							"day": 4,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide14_15",
							"survey_title": "Slide C14 & 15",
							"message": "Runners’ calorie needs are based on the “fuel” required to support basal metabolism, exercise training, activities of daily living, and the digestion & absorption of food.",
							"day": 4,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide16_17",
							"survey_title": "Slide C14 & 15",
							"message": "Runners nutritional needs will vary based on their unique characteristics, here are sample calculations for a male and female runner.",
							"day": 5,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide18_19_importanceOfNutrientsVideoMessage",
							"survey_title": "Slide C18, 19 & Importance Of Nutrients Video",
							"message": "It is also important to optimize the quality of calories eaten by choosing a variety of nutrient-rich foods.",
							"day": 5,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide20_21",
							"survey_title": "Slide C20 & 21",
							"message": "Runners can meet with the team dietitian to make sure they are eating the right amount and quality of foods.",
							"day": 6,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide22_23_breakfastRecipesVideo",
							"survey_title": "Slide C22, 23, & Breakfast Recipes Video",
							"message": "Runners that are under-fueling can increase energy intake by making gradual changes such as adding a snack to their current routine or eating a nutrient-rich breakfast each day.",
							"day": 6,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide22_23_breakfastRecipesVideo",
							"survey_title": "Slide C24 & Boost Your Snacks Video",
							"message": "Runners that are under-fueling can also increase intake by adding healthy, energy-dense foods such as nuts, avocadoes, and dried fruit to current meals and snacks.",
							"day": 7,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide25_eatingFrequencyHandout",
							"survey_title": "Slide C25 & Eating Frequency Handout",
							"message": "Pack your snacks each night so that you have nutrient-rich foods to eat frequently throughout the day.",
							"day": 7,
							"hour": 17,
							"minute": 0
						}
					]
				},
				{
					"campaign": "urn:campaign:ucla:runstrong:resources:nutrition:week2:withImages",
					"reminders": [
						{
							"survey_id": "slide1_2_fuelingTheExtraMileVideo",
							"survey_title": "Slide C01, 02 & Fueling The Extra Mile Video",
							"message": "Eating nutrient-rich whole food sources of carbohydrate, protein, and dietary fat optimally fuels endurance exercise.",
							"day": 8,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide3_4",
							"survey_title": "Slide C03 & 04",
							"message": "Carbohydrates are the primary energy source for moderate to high-intensity exercise, such as endurance running.",
							"day": 8,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide5",
							"survey_title": "Slide 05",
							"message": "Muscle glycogen is a primary storage site for carbohydrate & relates to endurance performance; as muscle glycogen lowers, runners become more fatigued.",
							"day": 9,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide6_7_8",
							"survey_title": "Slide C06, 07 & 08",
							"message": "Endurance exercise, paired with a diet rich in carbohydrates, optimizes muscle glycogen stores.",
							"day": 9,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide9",
							"survey_title": "Slide 09",
							"message": "Distance runners need approximately 6-10 grams of carbohydrate per kg of body weight each day; eating toward the higher end of the range is recommended during periods of heavy training.",
							"day": 10,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide10_11",
							"survey_title": "Slide C10 & 11",
							"message": "Eating a low carbohydrate diet during consecutive days of high mileage training significantly lowers muscle glycogen stores & may reduce performance.",
							"day": 10,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide12_13",
							"survey_title": "Slide C12 & 13",
							"message": "Runners’ carbohydrate needs may range from 300 to over 700 grams per day; here is a sample meal plan providing 500 grams of carbohydrate from nutrient-rich food sources.",
							"day": 11,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide14_15",
							"survey_title": "Slide C14 & 15",
							"message": "Protein foods provide essential amino acids that serve important roles to runners, such as maintaining muscle, healing damaged tissue, supporting immune system function, and forming key metabolic hormones.",
							"day": 11,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide16_17_vegetarianAthletesHandout",
							"survey_title": "Slide C16, 17, & Vegetarian Athletes Handout",
							"message": "Choose a variety of protein foods, such as meat, fish, eggs, dairy, soy, nuts, beans, & grains, to get enough of the essential amino acids; this is especially important for runners following a vegetarian or vegan diet.",
							"day": 12,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide18_19_20_proteinNeedsHandout",
							"survey_title": "Slide C18, 19, 20, & Protein Needs Handout",
							"message": "Runners need approximately 1.2 to 1.7 grams of protein per kg of body weight per day; eat moderate amounts (~15-20 grams) frequently throughout the day.",
							"day": 12,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide21_gainingWeightAndBldgMuscleHandout",
							"survey_title": "Slide C21 & Gaining Weight And Bldg Muscle Handout",
							"message": "Runners need approximately 1.2 to 1.7 grams of protein per kg of body weight per day; eat moderate amounts (~15-20 grams) frequently throughout the day.",
							"day": 13,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide22_23_24",
							"survey_title": "Slide C22, 23, & 24",
							"message": "Eating enough dietary fat also fuels distance running, among other benefits; “burning” fat to fuel exercise improves endurance by conserving muscle glycogen stores.",
							"day": 13,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide25_26_27",
							"survey_title": "Slide C25, 26, & 27",
							"message": "Endurance runners need 1 to 2 grams of fat per kg of body weight daily; aim to choose nutrient-rich whole food sources such as nuts, seeds, olives, avocado, fatty fish, and vegetable oil.",
							"day": 14,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "nutritionFactsLabelHandout",
							"survey_title": "SCAN: Nutrition Facts Label",
							"message": "Here is a handout with tips for purchasing optimal fuel sources at the grocery store & to use when preparing meals & snacks.",
							"day": 14,
							"hour": 17,
							"minute": 0
						}
					]
				},
				{
					"campaign": "urn:campaign:ucla:runstrong:resources:nutrition:week3:withImages",
					"reminders": [
						{
							"survey_id": "slide1_2",
							"survey_title": "Slide C01 & 02",
							"message": "Follow guidelines for building a “Performance Plate” to optimize energy levels, hydration status, recovery, and exercise performance.",
							"day": 15,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide3_4_buildingPerformancePlateHandout",
							"survey_title": "Slide C03, 04, & Building Performance Plate Handout",
							"message": "A “Performance Plate” contains a variety of foods including grains, lean protein, fruits & vegetables, healthy fats, and fluids.",
							"day": 15,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide5_6_creatingBalancedPerformancePlateVideo",
							"survey_title": "Slide C05, 06, & Creating Balanced Performance Plate Video",
							"message": "The “Performance Plate” for a “Moderate” training day represents runners’ typical needs during the season.",
							"day": 16,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide7_8",
							"survey_title": "Slide C07 & 08",
							"message": "During a “Moderate” training day about a third of the “Performance Plate” should be starchy foods such as rice, pasta, cereal, potato, beans & legumes.",
							"day": 16,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide9_10",
							"survey_title": "Slide C09 & 10",
							"message": "A “Hard” training day is when a runner has two or more intense training sessions; runners need more carbohydrate and total calories on these days.",
							"day": 17,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide11_12",
							"survey_title": "Slide C11 & 12",
							"message": "During a “Hard” training day about half of the “Performance Plate” should be starchy foods, the other half should be lean protein & vegetables.",
							"day": 17,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide13_14_15",
							"survey_title": "Slide C13, 14 & 15",
							"message": "An “Easy” day consists of little training, however, these days are not typical for a runner during the competitive season.  On “Easy” days about a quarter of the plate should be starchy foods.",
							"day": 18,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide16_17",
							"survey_title": "Slide C16 & 17",
							"message": "Runners should eat 2-4 healthy snacks between meals to avoid low blood sugar and fatigue.",
							"day": 18,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide18_19",
							"survey_title": "Slide C18 & 19",
							"message": "Snacks should contain at least two of the following food groups [grains, lean protein, fruit & vegetables, healthy fat].  Some examples include Greek yogurt topped with dried fruit, pretzels & string cheese.",
							"day": 19,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide20_miniFridgeMakeoverHandout",
							"survey_title": "Slide C20 & Mini Fridge Makeover Handout",
							"message": "Stock your kitchen or dorm room with food and supplies for making convenient on-the-go snacks!",
							"day": 19,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide21_22",
							"survey_title": "Slide C21 &amp; 22",
							"message": "Make sure to stay hydrated!  A loss of 2% or more of water weight can negatively affect physical and mental performance.",
							"day": 20,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide23_24",
							"survey_title": "Slide C23 & 24",
							"message": "Runners fluid needs vary based on their training level and sweat rate.  Use urine color to track your hydration status; a pale yellow urine color is ideal!",
							"day": 20,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide25_26_27",
							"survey_title": "Slide C25, 26, & 27",
							"message": "A sports dietitian can evaluate runners’ individual sweat rate & fluid needs.  Choosing foods high in water can also help with fluid intake.",
							"day": 21,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide28_29_foodsWithElectrolytesVideo",
							"survey_title": "Slide C28, 29, & Foods With Electrolytes Video",
							"message": "It is possible to overhydrate! Avoid over-consuming fluids and make sure to replenish electrolytes, such as sodium, after hard workouts.",
							"day": 21,
							"hour": 17,
							"minute": 0
						}
					]
				},
				{
					"campaign": "urn:campaign:ucla:runstrong:resources:nutrition:week4:withImages",
					"reminders": [
						{
							"survey_id": "slide1",
							"survey_title": "Slide 01",
							"message": "When runners eat is just as important as what they eat; especially before, during, and after long or higher intensity workouts.",
							"day": 22,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide2_3_4",
							"survey_title": "Slide C02, 03, & 04",
							"message": "A carbohydrate-rich snack or meal before exercise optimizes pre-workout energy levels and performance.",
							"day": 22,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide5_6_7",
							"survey_title": "Slide C05, 06, & 07",
							"message": "For optimal digestion and use of nutrients, the pre-exercise meal or snack should be moderate in protein & lower in fat and fiber.",
							"day": 23,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide8_9",
							"survey_title": "Slide C08 & 09",
							"message": "Don’t skip out on food before early morning workouts.  A small carbohydrate-rich snack (½ bagel, banana, or handful of dried fruit) digests quickly and provides energy for optimal performance. Hydrating before exercise is also important!",
							"day": 23,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide10_11_12",
							"survey_title": "Slide C10, 11, & 12",
							"message": "Eating a high carbohydrate snack is recommended to optimize muscle glycogen, blood sugar levels, and energy during long runs over 60 to 90 minute.",
							"day": 24,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide13_14_15",
							"survey_title": "Slide C13, 14, & 15",
							"message": "During long runs, it is recommended to eat about 30 grams of carbohydrate per hour and drink 6 to 8 ounces of fluids every 15-20 minutes.  Snack examples that digest quickly include fruit puree, energy gels or chews.",
							"day": 24,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide16",
							"survey_title": "Slide 16",
							"message": "During long runs, a carbohydrate & electrolyte beverage hydrates and provides needed carbohydrate and sodium.",
							"day": 25,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide17_18_replenishingYourBodyVideo",
							"survey_title": "Slide C17, 18, & Replenishing Your Body Video",
							"message": "To optimize post-exercise recovery, it is recommended to eat a snack within 30-minutes of finishing an intense workout or race.",
							"day": 25,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide19",
							"survey_title": "Slide 19",
							"message": "Eating a snack after exercise is most important after intense runs, and on days with more than one workout or competitive event.",
							"day": 26,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide20_21_fuelingForRecoveryHandout",
							"survey_title": "Slide C20, 21, & Fueling For Recovery Handout",
							"message": "The post-exercise snack should be rich in carbohydrate, moderate in protein, and lower in fat. Choose a cold liquid snack, such as chocolate milk or a smoothie if it is difficult to eat solid foods after exercise.",
							"day": 26,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide22_23_recoveryFactSheetHandout",
							"survey_title": "Slide C22, 23, & Recovery Fact Sheet Handout",
							"message": "Other post-exercise snack examples include yogurt with cereal or dried fruit, bagel & string cheese, a wrap with peanut butter and a banana.",
							"day": 27,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide24_25",
							"survey_title": "Slide C24 & 25",
							"message": "For every pound (16 ounces) of water lost during exercise, runners should drink 16 to 24 ounces of fluid.  To replenish salt lost in sweat, choose sodium-containing food & fluids post-exercise.",
							"day": 27,
							"hour": 17,
							"minute": 0
						},
						{
							"survey_id": "slide26_27_28_optimalBoneHealthHandout",
							"survey_title": "Slide C26, 27, 28, & Optimal Bone Health Handout",
							"message": "For optimal bone health and strength, it is recommended for runners to choose foods rich in calcium and vitamin D.",
							"day": 28,
							"hour": 10,
							"minute": 0
						},
						{
							"survey_id": "slide29",
							"survey_title": "Slide 29",
							"message": " There are several benefits of eating dairy foods. Chocolate milk is rich in calcium, vitamin D and contains the balance of carbohydrate and protein recommended for post-exercise recovery in runners.",
							"day": 28,
							"hour": 17,
							"minute": 0
						}
					]
				},
				{
					"campaign": "urn:campaign:ucla:runstrong:welcomemessage:nutrition",
					"reminders": [
						{
							"survey_id": "nutritionWeek1WelcomeMessage",
							"survey_title": "Week 1: Welcome Message",
							"message": "Welcome to Week 1 of the Run Strong app!  In the next 4 weeks we will be reviewing important nutrition topics for runners.  In Week 1 we will review the Importance of Adequate Energy.  You will receive daily nutrition tips with links to additional nutrition resources for you to view.  Over the weekend, you will receive the Recipe of the Week and an invitation to complete a brief 3 to 5 minute survey asking for your feedback about the app.  Please let us know if you have questions at any time.  Also, before we begin the week, please answer the following two questions about your running mileage & exercise this past week:",
							"day": 1,
							"hour": 9,
							"minute": 30
						},
						{
							"survey_id": "nutritionWeek2WelcomeMessage",
							"survey_title": "Week 2: Welcome Message",
							"message": "Welcome to Week 2 of the Run Strong app!  This week we will review the importance of Carbohydrate, Protein, and Dietary Fat for runners.  Like last week, you will receive daily nutrition tips with links to additional nutrition resources.  Over the weekend, you will also receive the Recipe of the Week and an invitation to complete the optional survey- we appreciate your feedback!  Also, before we begin the week, please answer the following questions about your running mileage &amp; exercise this past week:",
							"day": 8,
							"hour": 9,
							"minute": 30
						},
						{
							"survey_id": "nutritionWeek3WelcomeMessage",
							"survey_title": "Week 3: Welcome Message",
							"message": "Welcome to Week 3 of the Run Strong app!  This week will review how to Build A Performance Plate and discuss Tips for  Proper Hydration. You will receive nutrition tips with links to additional nutrition resources, the Recipe of the Week, and optional survey.  Have you tried one of the Recipes of the Week?  Also, before we begin the week, please answer the following two questions about your running mileage &amp; exercise this past week:",
							"day": 15,
							"hour": 9,
							"minute": 30
						},
						{
							"survey_id": "nutritionWeek4WelcomeMessage",
							"survey_title": "Week 4: Welcome Message",
							"message": "Welcome to Week 4 of the Run Strong app!  This is the last week of the 4-week review of important nutrition topics for runners.  We will cover Nutrient Timing and Bone-Building Nutrients.  You will receive the daily nutrition tips with links to additional nutrition resources, the Recipe of the Week, and optional survey.  We appreciate your feedback! Also, before we begin the week, please answer the following two questions about your running mileage & exercise this past week:",
							"day": 22,
							"hour": 9,
							"minute": 30
						}
					]
				},
				{
					"campaign": "urn:campaign:ucla:runstrong:assessments:nutrition",
					"reminders": [
						{
							"survey_id": "adequateEnergyAssessments",
							"survey_title": "Importance of Consuming Adequate Energy Assessments",
							"message": "You have a pending assessment",
							"day": 7,
							"hour": 14,
							"minute": 0
						},
						{
							"survey_id": "carbProteinDietaryFatAssessments",
							"survey_title": "Carbohydrate, Protein, & Dietary Fat Assessments",
							"message": "You have a pending assessment",
							"day": 14,
							"hour": 14,
							"minute": 0
						},
						{
							"survey_id": "performancePlateAndHydrationTipsAssessments",
							"survey_title": "Building a Performance Plate & Hydration Tips Assessments",
							"message": "You have a pending assessment",
							"day": 21,
							"hour": 14,
							"minute": 0
						},
						{
							"survey_id": "nutrientTimingBoneBuildingNutrientsAssessments",
							"survey_title": "Nutrient Timing & Bone Building Nutrients Assessments",
							"message": "You have a pending assessment",
							"day": 28,
							"hour": 14,
							"minute": 0
						}
					]
				},
				{
					"campaign": "urn:campaign:ucla:runstrong:recipes:nutrition:withImagesAndLinks",
					"reminders": [
						{
							"survey_id": "greekQuinoaAvocadoSalad",
							"survey_title": "Greek Quinoa & Avocado Salad",
							"message": "View recipe of the week!",
							"day": 6,
							"hour": 14,
							"minute": 0
						},
						{
							"survey_id": "summerPastaSalad",
							"survey_title": "Summer Pasta Salad",
							"message": "View recipe of the week!",
							"day": 13,
							"hour": 14,
							"minute": 0
						},
						{
							"survey_id": "cherryAlmondOatmealBreakfastSmoothie",
							"survey_title": "Cherry Almond Oatmeal Breakfast Smoothie",
							"message": "View recipe of the week!",
							"day": 20,
							"hour": 14,
							"minute": 0
						},
						{
							"survey_id": "chiliBakedPotato",
							"survey_title": "Chili Baked Potato",
							"message": "View recipe of the week!",
							"day": 27,
							"hour": 14,
							"minute": 0
						}
					]
				}
			]
			return settings_dates

	App.reqres.setHandler "settings_dates:get:all", ->
		console.log "settings_dates:get:all"
		API.getSettingsDates()