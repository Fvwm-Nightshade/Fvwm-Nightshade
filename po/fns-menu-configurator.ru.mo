��    <      �  S   �      (     )     ;     M     T     s     �     �     �  $   �       �        �     �  ;   �  S   '  �   {     /     5     S     \  	   n     x     }  
   �     �    �    �	  }   �
  �   3  L     I  [  �   �     d     i  l  y     �  
   �          
       N   '  	   v  )   �     �     �  �   �  �   �     0     9  	   >     H     W  1  e     �  ]   �  	     
          *       I     `      �     �  A   �  A   �  3   6  ?   j  '   �  E   �          0     1  "   J  O   m  �   �    ?     W  C   d     �  "   �     �                1     L  �  c  �  M  �   $  �  #   �   "    �"  +  �$     �%  &   �%  =  &     ](     x(     �(     �(  #   �(  �   �(     Z)  N   r)     �)      �)  k  �)  �   [+     /,     >,     Q,  &   m,     �,  �  �,     �.  �   �.  )   r/  )   �/     �/  ^   �/                /                            2       	       ;       0       6   .   -          9   (   #                                       !   $   %                       <   7   8   &      *                 ,       5              +   "   3   
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
PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE
Last-Translator: FULL NAME <EMAIL@ADDRESS>
Language-Team: Russian
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
  Общие Параметры  Иконка программы: Отменить Отменит/Выйти из меню Конфигураций. Изменит путь к программным иконкам. Изменить директорию иконок. Изменить путь к директории иконок. Изменить темы иконок. Изменить путь результатов меню файла. Создать Файл Определяет тип меню. Возможные имена типов: applications, settings, preferences, etc.При отсутствии определенного типа меню генерированное меню будет пустым! Рабочий стол: Иконка директории: поставите птичку для внетдения меню в меню. Введите полный путь меню для сохранения. Путь по умолчанию: $FVWM_USERDIR/.menu. Введите в это поле имя меню (его заглавие) где генерированные меню будут введены.Информация об этом отделе предоставлена в секции USAGE в мануале fns-menu-desktop. Ошибки FNS Меню Конфигурацией Рабочего Стола Генерировать Генерировать Меню. Получить помощь. Помощь Директория Иконк: Размер иконки: Тема Иконок: Если 'Use Icons' установлено и иконки для директории в меню не найдены тогда'gnome-fs-directory' иконки употреблены по умолчанию. Если тема иконок gnome не установлена то иконки по умолчанию не появятся. Другие иконки могут быть настроены тут. Введите только имя иконки исключая путь. Если 'Use Icons' установлено и иконки для программы не найдены, по умолчанию употребляются иконки от 'gnome-applications'. Если тема иконок gnome не установлена иконки по умолчанию не появятся. Другие иконки могут быть настроены тут. Введите только имя иконки исключая путь. При установки 'Использовать Иконки' употребляются мини-иконки с размером 24х24.Для измени размера иконок введите желанный размер в это поля. Если размер выбранной иконки не совпадает с выбранным размером, то размер иконки будет изменен если ImageMagick установлен в системе. Генерированные иконки сохранены в $FVWM_USERDIR/icons или же в директории специфицированной тут. Иначе иконка для данной вкладке не появится в меню. Если эта опция выбрана, меню появляются с заглавиями. По умолчанию заглавя отсутствуют В этом табе показаны  все XDG меню найденные в системе. Все выбранные меню будут включены в одно Fvwm меню. Похожие меню найденные в/etc/xdg/menus и ~/.config/menus/ following которые соблюдают спецификацииXDG меню показаны только в ~/.config/menus/. 
 Для пользовательской настройки менюпереключитесь в 'Single Menu' таб В этом табе вы можете настроит custom-assembled меню 'foo-bar.menu'директория пользовательских меню описана в XDG меню.
Запомните, если меню не существует то ничего не произойдет. Информация Префикс инсталляции: Далее проверьте содержание .xsession-errors в домашней папке,
 для выявления ошибок.При наличии большого количества меню выдается ошибка в .xsession-errors:

 'Module(0xXXX) command is too big (1008), limit is 1000.'

 Причиной является лимит длинны в 1000 символов у PipeRead а который использован длягенерации меню. Мы извиняемся из за проявленные неудобства. Меню Заглавие: Тип Меню: Меню в Меню в меню: Множественное Меню Меню не найденные. Для нахождения причины введите в терминал: 
' fvwm-menu-desktop -v ' Открыть Файл Позволить употребление мини-иконок в меню. Другое Путь Результатов. Переписывает имя основной среды рабочего стола. При наличии множественных рабочих сред в системеустанавливается $XDG_MENU_PREFIX. При употреблении этого поля он игнорируется. Возможные имена:gnome, kde, lxde, etc. Переписывает стандартную директорию XDG меню спецификацией. Стандартными директориями являются: /etc/xdg/menus и ~/.config/menus Вопросы Сохранить Сохранить Файл Сохранить Настройки. Выбрать Файл Устанавливает тему иконок. По умолчанию 'gnome', хотя все другие темы найденные в~/.icons или /usr/share/icons могут быть установлены кроме темы hicolor. Последняя является fallback темой по умолчанию. Имя темы должно совпасть с именем директории один в один. К примеру: /usr/share/icons/Mint-X => 'Mint-X'. Одиночное Меню Специфицирует заглавие главного меню использованного всплывающего окна команды Fvwm-аПо умолчанию 'FvwmMenu'. Использованные Иконки Использовать Заглавия Предупреждения Присутствуют не сохраненные изменения! продолжить? 