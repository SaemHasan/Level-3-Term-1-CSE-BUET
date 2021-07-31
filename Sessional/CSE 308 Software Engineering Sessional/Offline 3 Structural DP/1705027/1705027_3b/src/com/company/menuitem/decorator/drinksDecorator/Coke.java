package com.company.menuitem.decorator.drinksDecorator;

import com.company.menuitem.MenuItem;

public class Coke extends DrinksDecorator {
    private double price;

    public Coke(MenuItem item) {
        super(item,75);
        price = 75;
    }

    public Coke(MenuItem item, double price) {
        super(item,price);
        this.price = price;
    }

}
