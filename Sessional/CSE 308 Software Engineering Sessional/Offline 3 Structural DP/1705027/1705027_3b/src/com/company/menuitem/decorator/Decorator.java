package com.company.menuitem.decorator;

import com.company.menuitem.MenuItem;

public abstract class Decorator implements MenuItem {

    private MenuItem item;

    public Decorator(MenuItem item) {
        this.item = item;
    }

    public double getPrice() {
        return item.getPrice();
    }
}
