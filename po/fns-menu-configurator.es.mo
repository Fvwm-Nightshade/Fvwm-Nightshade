��    <      �  S   �      (     )     ;     M     T     s     �     �     �  $   �       �        �     �  ;   �  S   '  �   {     /     5     S     \  	   n     x     }  
   �     �    �    �	  }   �
  �   3  L     I  [  �   �     d     i  l  y     �  
   �          
       N   '  	   v  )   �     �     �  �   �  �   �     0     9  	   >     H     W  1  e     �  ]   �  	     
          *     6  I     �     �     �  #   �  )   �  ,     $   /  %   T  3   z     �  �   �     �     �  D   �  \   �  �   G       %        7     ?     Q     `     f     |     �  F  �  =  �  �   (     �  `   �  {    �   �     I      N   c  `      �!     �!  	   �!     �!     "  `   ""     �"  5   �"     �"     �"  �   �"  �   �#     s$     |$     �$     �$     �$  l  �$     -&  l   :&     �&     �&     �&  :   �&                /                            2       	       ;       0       6   .   -          9   (   #                                       !   $   %                       <   7   8   &      *                 ,       5              +   "   3   
            )      1          :             4       '     General Options  Application Icon: Cancel Cancel/Quit Menu Configurator. Change application icon path. Change directoy icon path. Change icon directory path. Change icon theme path. Change output path of the menu file. Create Folder Defines which type of menu should be found. Possible name types could be: applications, settings, preferences, etc. Note if the specified menu type doesn't exist the generated menu is empty! Desktop: Directory Icon: Enable this checkbox to insert generated menu(s) IN a menu. Enter here the FULL path of the menu to store. Default path is $FVWM_USERDIR/.menu. Enter in this field the name of the menu (its top title) where the generated menu(s) should insert. For more information see the USAGE section in the man page of fns-menu-desktop. Error FNS Menu Desktop Configurator Generate Generate menu(s). Get help. Help Icon Directory: Icon Size: Icon Theme: If 'Use Icons' is enabled and for a directory in a menu no icon is found 'gnome-fs-directory' as default icon is used. But if the gnome icon theme isn't installed no default icon appears. Another icon can defined here. Only the name of an icon is needed not the path! If 'Use Icons' is enabled and for an application no icon is found 'gnome-applications' as default icon is used. But if the gnome icon theme isn't installed no default icon appears. Another icon can defined here. Only the name of an icon is needed not the path! If 'Use Icons' is set, by default 24x24 mini-icons are used. If another size is desired change the wanted size in this field. If the specified icon isn't that size it is converted if ImageMagick is installed. Generated icons are saved in $FVWM_USERDIR/icons or the directory specified here. Otherwise no icon appears in the menu for that entry. If this option is set menus are generated with titles. Default is no titles. In this tab all XDG menus found on the system are shown. All selected menus will integrate in one Fvwm menu. Note that equal menus found under /etc/xdg/menus AND ~/.config/menus/ following the XDG menu specification only shown in ~/.config/menus/. 
If you want to generate a custom-assembled menu switch to the 'Single Menu' tab. In this tab you can define a custom-assembled menu 'foo-bar.menu' placed on another location as defined in the XDG menu definitions.
But remember, if the menu doesn't exist, nothing happens. Info Install-Prefix: It is a good idea to check .xsession-errors in the user home
for errors, too. One limitation exists - if there are too much
menus found an error occurs in .xsession-errors:

'Module(0xXXX) command is too big (1008), limit is 1000.'

This happens because PipeRead used for menu generation
has a command length limit of 1000 characters. Sorry for
that inconvinience. Menu Top Title: Menu Type: Menus in Menus in Menu: Multiple Menu No menus found! Check why from within a terminal with
' fvwm-menu-desktop -v ' Open File Option enables mini-icons in the menu(s). Other Output Path: Overrides the name of the main desktop environment installed on the system. If a system offers multiple desktop environments $XDG_MENU_PREFIX is typically set. It is ignored if this field is used. Possible names: gnome, kde, lxde, etc. Overrides the standard locations for XDG menu definitions. The standard locations are /etc/xdg/menus and ~/.config/menus if available. Question Save Save File Save settings. Select Folder Sets the used icon theme. Default is 'gnome' but all others found in ~/.icons or /usr/share/icons can used except the hicolor theme because it's the default fallback theme if no icon is found. Note that the theme name must be written exactly as the icon directory e.g. /usr/share/icons/Mint-X => 'Mint-X'. Single Menu Specifies the menu title of the top menu used by Fvwm's Popup command. Default is 'FvwmMenu'. Use Icons Use Titles Warning You have unsaved changes! Continue anyway? Project-Id-Version: FNS-MenuConfigurator
POT-Creation-Date: 2014-11-26 21:51+0200
PO-Revision-Date: 2015-02-15 23:34+0200
Last-Translator: Adonai Martin <adonai.martin@gmail.com>
Language-Team: Spanish
Language: Spanish
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
  Opciones generales  Icono de Aplicación: Cancelar Cancelar/Cerrar Menú Configurador. Cambiar la ruta de iconos de aplicación. Cambiar aplicación de directorio de iconos. Cambiar ruta de directorio de icono. Cambiar directorio de temas de icono. Cambiar directorio de salida del menú de archivos. Crear carpeta Define qué tipo de menú debe ser encontrado. Posibles tipos pueden ser: applications, settings, preferences, etc. Atención, si el tipo de menú especificado no existe, el menú generado está vacío! Escritorio: Icono de carpeta: Habilitar este checkbox para insertar menu(s) generados EN un menú. Escriba aquí la ruta COMPLETA en el menú para guardarla. Estándar es $FVWM_USERDIR/.menu. Escriba en el campo de nombre de menú (encima del título) donde los menú(s) generados deberían insertarse. Para más información vea la sección de USO en la página man de fns-menu-desktop. Error FNS Configurador del Menú Escritorio Generar Generar Menú(s). Obtenga ayuda. Ayuda Directorio de iconos: Tamaño de icono: Icono de tema usado: Si 'Usar Iconos' está activado y para un directorio en un menú sin ningún icono encontrado, 'gnome-fs-directory' será usado por defecto. Pero si el icono del tema de gnome no está instalado, ningún icono aparecerá por defecto. Otro icono puede ser definido aquí. ¡Sólo el nombre de un icono es necesario, no la ruta! Si 'Usar Iconos' está habilitado y para una aplicación ningún icono es encontrado, 'gnome-applications' será usado por defecto. Pero si el icono del tema de gnome no está instalado, ningún icono aparecerá por defecto. Otro icono puede ser definido aquí. Sólo el nombre de un icono es necesario, ¡no la ruta! Si 'Usar Iconos' está seleccionado, iconos de 24x24 serán usados por defecto. Si desea otro tamaño, establézcalo en este campo. Si el icono especificado no es de ese tamaño, será convertido, si ImageMagic está instalado. Los iconos generados se guardan en $FVWM_USERDIR/icons o el directorio especificado aquí. De otra manera ningún icono aparecerá en el menú para esa entrada. Si esta opción está activada, los menús son generados con títulos. Estándar es sin título. En esta pestaña todos los menús XDG encontrados en el sistema son mostrados. Todos los menús seleccionados, son integrados en un menú Fvwm. Nota: los menús idénticos encontrados en /etc/xdg/menus UND ~/.config/menus/, siguiendo la especificación de menú XDG, son solamente mostrados en ~/.config/menus/.
Si desea crear su menú propio, utilice la sección 'Menú único'. En esta sección usted puede crear un menú 'foo-bar.menu', que fue definido en otro lugar diferente a las especificaciones del menú XDG.
Pero recuerde, si el menú no existe, no pasa nada. Info Instalar-Prefijo: Una buena idea es comprobar los mensajes de error en .xsession-errors. Existe un límite - Si se encuentran muchos menús,
aparece el siguiente error en .xsession-errors:

'Module(0xXXX) command is too big (1008), limit is 1000.'

Esto sucede, porque PipeRead usada para generar el menú
tiene un límite de 100 caracteres. Perdón por este
inconveniente. Título superior del menú: Tipo de menú usado: Menús en Menú(s) en menú: Menú múltiple ¡No se han encontrado menús! Compruebe la causa desde un terminal con
' fvwm-menu-desktop -v ' Abrir archivo Opción para activar mini-iconos en el(los) menú(s). Otro Ruta de salida: Sobreescribe el nombre del escritorio principal, que fue instalado en el sistema. Si un sistema ofrece múltiples escritorios, $XDG_MENU_PREFIX es típicamente seleccionado, pero se ignora si este campo es usado. Posibles nombres: gnome, kde, lxde, etc. Sobreescribir la ubicación estándar para las definiciones de menú XDG. Los sitios estándar son /etc/xdg/menus y ~/.config/menus si está disponible. Pregunta Guardar Guardar archivo Guardar configuración. Seleccionar carpeta Establecer el icono de tema usado. Por defecto es 'gnome', pero otros encontrados en ~/.icons y /usr/share/icons pueden ser usados. Exceptuando tema 'hicolor' porque es el tema por defecto de reserva si ningún icono es encontrado. Atención al nombre del tema, debe de ser escrito exactamente como el directorio de los iconos: /usr/share/icons/Mint-X => 'Mint-X'. Menú Único Especifica el título del menú principal que es usado por el comando Fvwm popup. Por defecto es 'FvwmMenu'. Usar Iconos Utilizar títulos Advertencia ¡Tiene cambios no guardados! ¿Continuar de todas formas? 