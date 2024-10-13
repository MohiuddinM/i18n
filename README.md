# i18n

![tests](https://github.com/MohiuddinM/i18n/workflows/test/badge.svg)
[![pub package](https://img.shields.io/pub/v/i18n.svg)](https://pub.dev/packages/i18n)

Simple internationalization package for Dart and Flutter. This package now supports hot reload and
is tested on
latest versions of Flutter.

# Overview

Write your messages into YAML files, and let this package generate convenient Dart classes from those files.

Turn this **YAML** file:

    lib/messages.i18n.yaml
    
    button:
      save: Save
      load: Load
    users:
      welcome(String name): "Hello $name!"
      logout: Logout

Into these **generated** Dart classes:

    class Messages {
        const Messages();
        ButtonMessages get button => ButtonExampleMessages(this);
        UsersMessages get users => UsersExampleMessages(this);
    }
    class ButtonMessages {
        final Messages _parent;
        const ButtonMessages(this._parent);
        String get save => "Save";
        String get load => "Load";
    }
    class UsersMessages {
        final Messages _parent;
        const UsersMessages(this._parent);
        String get logout => "Logout";
        String welcome(String name) => "Hello $name!";
    }

... and **use them** in your code - plain and simple.

    Messages m = Messages();
    print(m.users.welcome('World'));
    // outputs: Hello World!

Package is an extension (custom builder) for [build_runner](https://pub.dartlang.org/packages/build_runner)
(Dart standard for source generation) and it can be used with Flutter, AngularDart
or any other type of Dart project.

## Motivation and goals

* The official Dart/Flutter approach to i18n seems to be ... complicated and kind of ... heavyweight.
* I would like my messages to be **checked during compile time**. Is that message really there?
* Key to the localized message shouldn't be just some arbitrary String, it should be a **getter method**!
* And if the message takes some **parameters**, the method should take those parameters! 
* I like to bundle messages into thematic groups, the i18n tool should support that and help me with it.
* Dart has awesome **string interpolation**, I want to leverage that!
* I like build_runner and code generation.

## Solution

Write your messages into a YAML file:

    messages.i18n.yaml (default messages):
    
    generic:
      ok: OK
      done: DONE
    invoice:
      create: Create invoice
      delete: Delete invoice

Write your translations into other YAML files:

    messages_de.i18n.yaml (_de = German translation)
    
    generic:
      ok: OK
      done: ERLEDIGT
    invoice:
      create: Rechnung erstellen
      delete: Rechnung löschen

... run the `webdev` tool, or `build_runner` directly, and use your messages like this:

    Messages m = Messages();
    print(m.generic.ok); // output: OK
    print(m.generic.done); // output: DONE
    
    m = Messages_de();
    print(m.generic.ok); // output: OK
    print(m.generic.done); // output: ERLEDIGT

## Parameters and pluralization

The implementation is VERY straightforward, which allows you to do all sorts of crazy stuff:

    invoice:
      create: Create invoice
      delete: Delete invoice
      help: "Use this function
      to generate new invoices and stuff.
      Awesome!"
      count(int cnt): "You have created $cnt ${_plural(cnt, one:'invoice', many:'invoices')}."
    apples:
      _apples(int cnt): "${_plural(cnt, one:'apple', many:'apples')}"
      count(int cnt): "You have eaten $cnt ${_apples(cnt)}."

Now see the generated classes:

    class Messages {
        const Messages();
        InvoiceMessages get invoice => InvoiceExampleMessages(this);        
        ApplesMessages get apples => ApplesExampleMessages(this);
    }
        
    class InvoiceMessages {
        final Messages _parent;
        const InvoiceMessages(this._parent);
        String get create => "Create invoice";
        String get help => "Use this function to generate new invoices and stuff. Awesome!";
        String get delete => "Delete invoice";
        String count(int cnt) => "You have created $cnt ${_plural(cnt, one:'invoice', many:'invoices')}.";
    }
    
    class ApplesMessages {
        final Messages _parent;
        const ApplesMessages(this._parent);
        String _apples(int cnt) => "${_plural(cnt, one:'apple', many:'apples')}";
        String count(int cnt) => "You have eaten $cnt ${_apples(cnt)}.";
    }         

See how you can **reuse** the pluralization of `_apples(int cnt)`? (nice!)

There are three functions you can use in your message:

    String _plural(int count, {String zero, String one, String two, String few, String many, String other})

    String _cardinal(int count, {String zero, String one, String two, String few, String many, String other})

    String _ordinal(int count, {String zero, String one, String two, String few, String many, String other})

`_plural` and `_cardinal` do the same. I just felt that `_plural`
is a little bit less scary name :-)

We need only two forms of the word "apple" in English. "Apple" (one) and "apples" (many).
But in some languages like Czech, we need three:

    apples:
      _apples(int cnt): "${_plural(cnt, one:'jablko', few: 'jablka', many:'jablek')}"

See also:

* http://cldr.unicode.org/index/cldr-spec/plural-rules
* https://www.unicode.org/cldr/charts/latest/supplemental/language_plural_rules.html

## How to use generated classes

How to decide what translation to use (ExampleMessages_de?, ExampleMessages_hu?) **is up to you**.
The package simply generates message classes, that's all.

    import 'messages.i18n.dart';
    import 'messages_de.i18n.dart' as de;
    
    void main() async {
      Messages m = Messages();
      print(m.apples.count(1));
      print(m.apples.count(2));
      print(m.apples.count(5));
    
      m = de.Messages_de(); // see? ExampleMessages_cs extends ExampleMessages
      print(m.apples.count(1));
      print(m.apples.count(2));
      print(m.apples.count(5));    
    }    

Where and how to store instances of these message classes - 
again, **up to you**. I would consider ScopedModel for Flutter and registering
messages instance into dependency injection in AngularDart.

But in this case a singleton would be acceptable also.

## How to use with Flutter

Create YAML file with your messages, for example:

    lib/messages/foo.i18n.yaml

Add `build_runner` as a dev_dependency and `i18n` as a dependency to `pubspec.yaml`:

    dependencies:
      flutter:
        sdk: flutter
      i18n: any
      ...
    
    dev_dependencies:
      build_runner: any
      flutter_test:
        sdk: flutter

Open a terminal and in the root of your Flutter project run:

    flutter packages pub run build_runner watch

... and keep it running. Your message classes will appear next to YAML files and will be
rebuilt automatically each time you change the source YAML.

For one-time (re)build of your messages run:

    flutter packages pub run build_runner build

Import generated messages and use them:

    import 'packages:my_app/messages/foo.i18n.dart'
    
    ...
    
    Foo m = Foo();
    return Text(m.bar);
    ...

## How to use with AngularDart

You are probably using `webdev` tool already, so you just need to add `i18n`
as a dependency and **that's all**.

## Custom pluralization

The package can correctly decide between 'one', 'few', 'many', etc. only for
English and Czech (for now). But you can easily plug your own language,
see [example/main.dart](example/main.dart)
and [Czech](lib/src/cs.dart) and [English](lib/src/en.dart)
implementation.

If you implement support for your language, please let me know,
I'll gladly embed it into the package. 