package com.company.menuitem.decorator.appetizerDecorator;

import com.company.menuitem.decorator.Decorator;
import com.company.menuitem.MenuItem;

public abstract class AppetizerDecorator extends Decorator {
    private double price;

    public AppetizerDecorator(MenuItem item) {
        super(item);
        price = 100;
    }

    public AppetizerDecorator(MenuItem item, double price) {
        super(item);
        this.price = price;
    }

    public double getPrice(){
        return price + super.getPrice();
    }
}
