package com.company.menuitem.decorator.drinksDecorator;

import com.company.menuitem.MenuItem;

public class Coffee extends DrinksDecorator {
    private double price;

    public Coffee(MenuItem item) {
        super(item, 150);
        price = 150;
    }

    public Coffee(MenuItem item, double price) {
        super(item,price);
        this.price = price;
    }
}
