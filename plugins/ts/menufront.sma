/* AMX Mod X
*   Menus Front-End Plugin
*
* by the AMX Mod X Development Team
*  originally developed by OLO
*
* This file is part of AMX Mod X.
*
*
*  This program is free software; you can redistribute it and/or modify it
*  under the terms of the GNU General Public License as published by the
*  Free Software Foundation; either version 2 of the License, or (at
*  your option) any later version.
*
*  This program is distributed in the hope that it will be useful, but
*  WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
*  General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program; if not, write to the Free Software Foundation,
*  Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*
*  In addition, as a special exception, the author gives permission to
*  link the code of this program with the Half-Life Game Engine ("HL
*  Engine") and Modified Game Libraries ("MODs") developed by Valve,
*  L.L.C ("Valve"). You must obey the GNU General Public License in all
*  respects for all of the code used other than the HL Engine and MODs
*  from Valve. If you modify this file, you may extend this exception
*  to your version of the file, but you are not obligated to do so. If
*  you do not wish to do so, delete this exception statement from your
*  version.
*/

#include <amxmodx>
#include <amxmisc>

new g_menuPosition[33]

#define MENUS_NUMBER 16

new g_menuBody[MENUS_NUMBER][] = {
  "KICK_PLAYER",
  "BAN_PLAYER",
  "SLAP_SLAY",
  "TEAM_PLAYER",

  "CHANGEL",
  "VOTE_MAPS",

  "SPECH_STUFF",
  "CLIENT_COM",

  // Next Page

  "SERVER_COM",
  "CVARS_SET",
  "CONFIG",
  "LANG_SET",
  "STATS_SET",

  "PAUSE_PLUG",
  "RES_WEAP",

  "TELE_PLAYER" /* Last is Teleport menu - if you want to move it
                       change also code in displayMenu (look for fun module check) */
}

new g_menuCmd[MENUS_NUMBER][] = {
  "amx_kickmenu",
  "amx_banmenu",
  "amx_slapmenu",
  "amx_teammenu",

  "amx_mapmenu",
  "amx_votemapmenu",

  "amx_speechmenu",
  "amx_clcmdmenu",

  // Next Page

  "amx_cmdmenu",
  "amx_cvarmenu",
  "amx_cfgmenu",
  "amx_setlangmenu",
  "amx_statscfgmenu",

  "amx_pausecfgmenu",
  "amx_restmenu",

  "amx_teleportmenu"
}

// Second value sets if menu is only for CS...
new g_menuAccess[MENUS_NUMBER][2] = {
  {ADMIN_KICK,0},
  {ADMIN_BAN,0},
  {ADMIN_SLAY,0},
  {ADMIN_LEVEL_A,1},

  {ADMIN_MAP,0},
  {ADMIN_MAP,0},

  {ADMIN_MENU,0},
  {ADMIN_LEVEL_A,0},

  // Next Page

  {ADMIN_MENU,0},
  {ADMIN_CVAR,0},
  {ADMIN_MENU,0},
  {ADMIN_CFG,0},
  {ADMIN_CFG,0},

  {ADMIN_CFG,0},
  {ADMIN_CFG,1},

  {ADMIN_LEVEL_A,0}
}

new g_coloredMenus
new g_cstrikeRunning
new g_funModule

public plugin_init() {
  register_plugin("Menus Front-End",AMXX_VERSION_STR,"AMXX Dev Team")  

  register_dictionary("menufront.txt")
  register_dictionary("common.txt")

  register_menucmd(register_menuid("AMX Mod X Menu"),1023,"actionMenu") 
  register_clcmd("amxmodmenu","cmdMenu",ADMIN_MENU,"- displays menus")    

  g_coloredMenus = colored_menus()
  g_cstrikeRunning = cstrike_running()
  g_funModule = is_module_loaded("Fun")
}

public actionMenu(id,key) {
  switch (key) {
    case 8: displayMenu(id,++g_menuPosition[id])
    case 9: displayMenu(id,--g_menuPosition[id])
    default: client_cmd(id, g_menuCmd[ g_menuPosition[id] * 8 + key ] )
  }
  return PLUGIN_HANDLED
}

displayMenu(id,pos) {
  if (pos < 0)  return
    
  new menuBody[512]
  new b = 0
  new start = pos * 8
  
  if ( start >= MENUS_NUMBER )
    start = pos = g_menuPosition[id] = 0
      
  new len = format(menuBody,511,
   g_coloredMenus ? "\yAMX Mod X Menu\R%d/%d^n\w^n" : "AMX Mod X Menu %d/%d^n^n" , pos+1, 2 )
    
  new end = start + 8
  new keys = MENU_KEY_0
  
  if (end > MENUS_NUMBER )
    end = MENUS_NUMBER
    
  new flags = get_user_flags(id)
    
  for (new a = start; a < end; ++a) {
      if ( a == MENUS_NUMBER - 1 && !g_funModule ) 
        continue // checks if there is fun module for teleport menu
  
      if ( (flags & g_menuAccess[a][0]) && ( g_menuAccess[a][1] ? g_cstrikeRunning : 1 ) ) {
        keys |= (1<<b)
        len += format(menuBody[len],511-len,"%d. %L^n",++b, id, g_menuBody[ a ] )
      }
      else {
        ++b     
        if ( g_coloredMenus )
          len += format(menuBody[len],511-len, "\d%d. %L^n\w",b, id, g_menuBody[ a ] )
        else
          len += format(menuBody[len],511-len, "#. %L^n", id, g_menuBody[ a ] )

      }
  }
      
  if (end != MENUS_NUMBER ) {
    format(menuBody[len],511-len,"^n9. %L...^n0. %s", id, "MORE", id, pos ? "BACK" : "EXIT")
    keys |= MENU_KEY_9
  }
  else format(menuBody[len],511-len,"^n0. %s", id, pos ? "BACK" : "EXIT")
 
  show_menu(id,keys,menuBody)
}

public cmdMenu(id,level,cid) {
  if (cmd_access(id,level,cid,1))
    displayMenu(id,g_menuPosition[id] = 0)
  return PLUGIN_HANDLED
}