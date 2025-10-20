warning: in the working copy of 'CRM/web/WEB-INF/web.xml', LF will be replaced by CRLF the next time Git touches it
[1mdiff --git a/CRM/web/WEB-INF/web.xml b/CRM/web/WEB-INF/web.xml[m
[1mindex ac608b5..cb67369 100644[m
[1m--- a/CRM/web/WEB-INF/web.xml[m
[1m+++ b/CRM/web/WEB-INF/web.xml[m
[36m@@ -28,6 +28,18 @@[m
         <servlet-name>LogoutController</servlet-name>[m
         <servlet-class>controller.LogoutController</servlet-class>[m
     </servlet>[m
[32m+[m[32m    <servlet>[m
[32m+[m[32m        <servlet-name>ManageProfileServlet</servlet-name>[m
[32m+[m[32m        <servlet-class>controller.ManageProfileServlet</servlet-class>[m
[32m+[m[32m    </servlet>[m
[32m+[m[32m    <servlet>[m
[32m+[m[32m        <servlet-name>ChangePassword</servlet-name>[m
[32m+[m[32m        <servlet-class>controller.ChangePasswordServlet</servlet-class>[m
[32m+[m[32m    </servlet>[m
[32m+[m[32m    <servlet>[m
[32m+[m[32m        <servlet-name>changeInformation</servlet-name>[m
[32m+[m[32m        <servlet-class>controller.changeInformation</servlet-class>[m
[32m+[m[32m    </servlet>[m
     <servlet-mapping>[m
         <servlet-name>LoginController</servlet-name>[m
         <url-pattern>/login</url-pattern>[m
[36m@@ -56,4 +68,16 @@[m
         <servlet-name>LogoutController</servlet-name>[m
         <url-pattern>/logout</url-pattern>[m
     </servlet-mapping>[m
[32m+[m[32m    <servlet-mapping>[m
[32m+[m[32m        <servlet-name>ManageProfileServlet</servlet-name>[m
[32m+[m[32m        <url-pattern>/manageProfile</url-pattern>[m
[32m+[m[32m    </servlet-mapping>[m
[32m+[m[32m    <servlet-mapping>[m
[32m+[m[32m        <servlet-name>ChangePassword</servlet-name>[m
[32m+[m[32m        <url-pattern>/changePassword</url-pattern>[m
[32m+[m[32m    </servlet-mapping>[m
[32m+[m[32m    <servlet-mapping>[m
[32m+[m[32m        <servlet-name>changeInformation</servlet-name>[m
[32m+[m[32m        <url-pattern>/changeInformation</url-pattern>[m
[32m+[m[32m    </servlet-mapping>[m
 </web-app>[m
