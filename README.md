# Typescript Doclet
Experimental Valadoc Doclet to generate Typescript Definition files for Gjs and node-gtk.

## Valadoc Api Reference

https://benwaffle.github.io/vala-language-server/

## Building

On elementary OS or Ubuntu run:

```bash
sudo add-apt-repository ppa:vala-team
sudo apt update
sudo apt install valac valadoc libvaladoc-dev libgee-0.8* build-essential python3 python3-pip python3-setuptools python3-wheel ninja-build
```

Install meson:

```bash
pip3 install --user meson
# Maybe you need to add the meson install path to you PATH variable:
echo "export PATH=\$HOME/.local/bin:\$PATH" >> ~/.bashrc # For bash or ~/.zshrc for ZSH
```

Install Node.js and NPM:

```bash
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
nvm install node
```

Install NPM dependencies

```bash
npm install
```

Now you can build the Valadoc Doclet with with:

```bash
npm run build
```

And build the Typescript Type Definition files:
```bash
npm run types
```

## Visual Studio Code

As a Typescript developer you don't want to code without autocompletion - [You also have that with Vala](https://wiki.gnome.org/Projects/Vala/Tools/VisualStudioCode).