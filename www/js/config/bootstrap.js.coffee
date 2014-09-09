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
          <displayLabel>Number One - textOneToTen</displayLabel>
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
          <displayLabel>Number Three - textBigRange</displayLabel>
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
      </contentList>
   </survey>
  </surveys>
</campaign>
"""