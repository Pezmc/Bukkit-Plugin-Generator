package com.bukkit.<yourname>.<pluginname>;

import org.bukkit.Location;
import org.bukkit.entity.Player;
import org.bukkit.event.player.PlayerChatEvent;
import org.bukkit.event.player.PlayerEvent;
import org.bukkit.event.player.PlayerListener;
import org.bukkit.event.player.PlayerMoveEvent;

/**
 * Handle events for all Player related events
 * @author <yourname>
 */
public class <pluginname>PlayerListener extends PlayerListener {
    private final <pluginname> plugin;

    public <pluginname>PlayerListener(<pluginname> instance) {
        plugin = instance;
    }

    //Insert Player related code here
}

