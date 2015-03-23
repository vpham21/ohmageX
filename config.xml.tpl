<?xml version='1.0' encoding='utf-8'?>
<widget id="<%= bundle_id %>" version="2.0.0" xmlns="http://www.w3.org/ns/widgets" xmlns:cdv="http://cordova.apache.org/ns/1.0">
    <name><%= app_name %></name>
    <description>
        <%= description %>
    </description>
    <author email="<%= author.email %>" href="<%= author.url %>">
        <%= author.name %>
    </author>
    <content src="index.html" />
    <platform name="ios">
        <!-- iOS 8.0+ -->
        <!-- iPhone 6 Plus  -->
        <icon src="../res/<%= image_folder %>/ios/icons/Icon-60@3x.png" width="180" height="180" />
        <!-- iOS 7.0+ -->
        <!-- iPhone / iPod Touch  -->
        <icon src="../res/<%= image_folder %>/ios/icons/Icon-60.png" width="60" height="60" />
        <icon src="../res/<%= image_folder %>/ios/icons/Icon-60@2x.png" width="120" height="120" />
        <!-- iPad -->
        <icon src="../res/<%= image_folder %>/ios/icons/Icon-76.png" width="76" height="76" />
        <icon src="../res/<%= image_folder %>/ios/icons/Icon-76@2x.png" width="152" height="152" />
        <!-- iOS 6.1 -->
        <!-- Spotlight Icon -->
        <icon src="../res/<%= image_folder %>/ios/icons/Icon-Small-40.png" width="40" height="40" />
        <icon src="../res/<%= image_folder %>/ios/icons/Icon-Small-40@2x.png" width="80" height="80" />
        <!-- iPhone / iPod Touch -->
        <icon src="../res/<%= image_folder %>/ios/icons/Icon.png" width="57" height="57" />
        <icon src="../res/<%= image_folder %>/ios/icons/Icon@2x.png" width="114" height="114" />
        <!-- iPad -->
        <icon src="../res/<%= image_folder %>/ios/icons/Icon-72.png" width="72" height="72" />
        <icon src="../res/<%= image_folder %>/ios/icons/Icon-72@2x.png" width="144" height="144" />

        <!-- Other Icons -->
        <icon src="../res/<%= image_folder %>/ios/icons/Icon-Small-50.png" width="50" height="50" />
        <icon src="../res/<%= image_folder %>/ios/icons/Icon-Small-50@2x.png" width="100" height="100" />
        <icon src="../res/<%= image_folder %>/ios/icons/Icon-Small.png" width="29" height="29" />
        <icon src="../res/<%= image_folder %>/ios/icons/Icon-Small@2x.png" width="58" height="58" />

    </platform>
    <access origin="*" />
</widget>
