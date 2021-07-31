package com.company.menuitem.decorator.appetizerDecorator;

import com.company.menuitem.MenuItem;

public class FrenchFries extends AppetizerDecorator{

    public FrenchFries(MenuItem item) {
        super(item);
    }

    public FrenchFries(MenuItem item, double price) {
        super(item, price);
    }
}
