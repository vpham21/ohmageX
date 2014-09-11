# For testing, Bootstrap contains:
# sample XML with a text prompt
@Bootstrap = """
<campaign>
  <campaignUrn>urn:campaign:ca:ucla:ohmage_test:prompt_types_test</campaignUrn>
  <campaignName>Prompt Types Test</campaignName>
  <serverUrl>https://test.mobilizelabs.org/</serverUrl>

  <surveys>
   <survey>
      <id>textSurvey</id>
      <title>Text Survey</title>
      <description>This is a survey to test behavior of the text prompt type.</description>
      <submitText>Done with the text survey</submitText>
      <showSummary>false</showSummary>
      <editSummary>false</editSummary>
      <summaryText>Number Test</summaryText>
      <anytime>true</anytime>
    
      <contentList>
        
        <prompt>
          <id>textOneToTen</id>
          <displayType>event</displayType>
          <displayLabel>Text Short: textOneToTen</displayLabel>
          <promptText>Write some text.</promptText>
          <abbreviatedText>Write some text.</abbreviatedText>
          <promptType>text</promptType>
           <properties>
            <property>
              <key>min</key>
              <label>1</label>
            </property>
            <property>
              <key>max</key>
              <label>10</label>
            </property>
            </properties>
          <default>Hello.</default>
          <skippable>true</skippable>
          <skipLabel>Skip</skipLabel>
        </prompt>
        <message>
          <id>BetweenTextsMessage</id>
          <messageText>Number Two - Here is a message between some text.</messageText>
        </message>
        <prompt>
          <id>textBigRange</id>
          <displayType>event</displayType>
          <displayLabel>Text Long: textBigRange</displayLabel>
          <promptText>Write some text.</promptText>
          <abbreviatedText>Write some text.</abbreviatedText>
          <promptType>text</promptType>
           <properties>
            <property>
              <key>min</key>
              <label>100</label>
            </property>
            <property>
              <key>max</key>
              <label>1000</label>
            </property>
           </properties>
           <default>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</default>
          <skippable>true</skippable>
          <skipLabel>Skip</skipLabel>
        </prompt>
        <prompt>
          <id>WithFriends</id>
          <displayLabel>Single Choice: With Friends</displayLabel>
          <displayType>category</displayType>
          <promptText>Did you go anywhere with friends?</promptText>
          <abbreviatedText>going with Friends</abbreviatedText>
          <promptType>single_choice</promptType>
          <condition>NumHoursExercise &gt; 0</condition>
          <skippable>true</skippable>
          <skipLabel>Skip</skipLabel>
          <properties>
            <property>
              <key>0</key>
              <label>Yes</label>
            </property>
            <property>
              <key>1</key>
              <label>No</label>
            </property>
          </properties>
        </prompt>
        <prompt>
          <id>DistanceUnit</id>
          <displayLabel>Multi Choice: Distance Unit</displayLabel>
          <displayType>metadata</displayType>
          <promptText>What unit was that distance?</promptText>
          <abbreviatedText>Distance Unit</abbreviatedText>
          <promptType>multi_choice</promptType>
          <default>0</default>
          <condition>
            (Distance != NOT_DISPLAYED) and
            (Distance != SKIPPED)
          </condition>
          <skippable>false</skippable>
          <properties>
            <property>
              <key>0</key>
              <label>Feet</label>
              <value>1</value>
            </property>
            <property>
              <key>1</key>
              <label>Meters</label>
              <value>3.2808399</value>
            </property>
            <property>
              <key>2</key>
              <label>Kilometers</label>
              <value>3280.8399</value>
            </property>
            <property>
              <key>3</key>
              <label>Miles</label>
              <value>5280</value>
            </property>
          </properties>
        </prompt>
        <prompt>
          <id>singleChoiceCustom1</id>
          <displayType>event</displayType>
          <displayLabel>Single Choice Custom: blank example</displayLabel>
          <promptText>Add a choice.</promptText>
          <abbreviatedText>Add a choice.</abbreviatedText>
          <promptType>single_choice_custom</promptType>
          <skippable>true</skippable>
          <skipLabel>Skip</skipLabel>
        </prompt>
        <prompt>
          <id>multiChoiceCustom1</id>
          <displayType>event</displayType>
          <displayLabel>Multi Choice Custom: blank example</displayLabel>
          <promptText>Add a choice:</promptText>
          <abbreviatedText>add a choice</abbreviatedText>
          <promptType>multi_choice_custom</promptType>
          <skippable>true</skippable>
          <skipLabel>Skip</skipLabel>
        </prompt>
      </contentList>
   </survey>
  </surveys>
</campaign>
"""