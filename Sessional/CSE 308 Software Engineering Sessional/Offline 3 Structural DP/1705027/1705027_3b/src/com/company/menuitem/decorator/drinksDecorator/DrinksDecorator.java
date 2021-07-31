package com.company.menuitem.decorator.drinksDecorator;

import com.company.menuitem.decorator.Decorator;
import com.company.menuitem.MenuItem;

public abstract class DrinksDecorator extends Decorator {

    private double price;

    public DrinksDecorator(MenuItem item,double price) {
        super(item);
        this.price=price;
    }

    public double getPrice() {
        return price+super.getPrice();
    }
}
