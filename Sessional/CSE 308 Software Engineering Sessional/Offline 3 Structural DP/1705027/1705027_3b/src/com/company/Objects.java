package com.company;

import com.company.menuitem.MenuItem;
import com.company.menuitem.decorator.appetizerDecorator.FrenchFries;
import com.company.menuitem.decorator.appetizerDecorator.OnionRings;
import com.company.menuitem.decorator.drinksDecorator.Coffee;
import com.company.menuitem.decorator.drinksDecorator.Coke;
import com.company.menuitem.pizza.Beef_Pizza;
import com.company.menuitem.pizza.Veggi_Pizza;

public class Objects {
    MenuItem []obj = new MenuItem[100];
    public Objects() {
        MenuItem obj1 = new Beef_Pizza();
        obj1 = new FrenchFries(obj1);
        obj[0] = obj1;

        MenuItem obj2 = new Veggi_Pizza();
        obj2 = new OnionRings(obj2);
        obj[1] = obj2;

        MenuItem obj3 = new Veggi_Pizza();
        obj3 = new FrenchFries(obj3);
        obj3 = new Coke(obj3);
        obj[2] = obj3;

        MenuItem obj4 = new Veggi_Pizza();
        obj4 = new OnionRings(obj4);
        obj4 = new Coffee(obj4);
        obj[3] = obj4;

        MenuItem obj5 = new Beef_Pizza();
        obj[4] = obj5;
    }

    public void show_prices(){
        System.out.println("Price of Beef Pizza with French fry : "+ obj[0].getPrice());
        System.out.println("Price of Veggi Pizza with onion rings : "+ obj[1].getPrice());
        System.out.println("Price of A combo meal with Veggi Pizza, French Fry and Coke : "+obj[2].getPrice());
        System.out.println("Price of A combo meal with Veggi Pizza, Onion Rings and Coffee : "+obj[3].getPrice());
        System.out.println("Price of A Beef Pizza only : "+ obj[4].getPrice());
    }
}
