#!/bin/sh

export DOTFILES_DIR="$( cd "$( dirname "$0" )" && pwd )"

# change time zone
echo "==========================================================="
echo "             changing timezone to America/Chicago          "
echo "-----------------------------------------------------------"
sudo ln -fs /usr/share/zoneinfo/America/Chicago /etc/localtime
sudo dpkg-reconfigure --frontend noninteractive tzdata

echo "==========================================================="
echo "         installing custom packages and updating clock     "
echo "-----------------------------------------------------------"
sudo apt-get update && sudo apt-get install -y lsb-release
sudo hwclock --hctosys

echo "==========================================================="
echo "             installing oh-my-zsh                          "
echo "-----------------------------------------------------------"
wget -q https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O ./install_zsh.sh
chmod +x ./install_zsh.sh
export ZSH=$HOME/.oh-my-zsh
export ZSH_CUSTOM=$HOME/.oh-my-zsh/custom
sh ./install_zsh.sh --unattended --keep-zshrc
rm -rf $ZSH/*.md $ZSH/*.txt $ZSH/.git $ZSH/.github ./install_zsh.sh

echo "==========================================================="
echo "             cloning zsh-autosuggestions                   "
echo "-----------------------------------------------------------"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
echo "==========================================================="
echo "             cloning zsh-syntax-highlighting               "
echo "-----------------------------------------------------------"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
echo "==========================================================="
echo "             cloning zsh-completions                       "
echo "-----------------------------------------------------------"
git clone https://github.com/zsh-users/zsh-completions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
echo "==========================================================="
echo "             cloning powerlevel10k                         "
echo "-----------------------------------------------------------"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
echo "==========================================================="
echo "             import exportsrc                              "
echo "-----------------------------------------------------------"
cat $DOTFILES_DIR/.exportsrc >> $HOME/.exportsrc
echo "==========================================================="
echo "             import zshrc                                  "
echo "-----------------------------------------------------------"
cat $DOTFILES_DIR/.zshrc > $HOME/.zshrc
echo "==========================================================="
echo "             import powerlevel10k                          "
echo "-----------------------------------------------------------"
cat $DOTFILES_DIR/.p10k.zsh > $HOME/.p10k.zsh
echo "==========================================================="
echo "             import bashrc                                 "
echo "-----------------------------------------------------------"
cat $DOTFILES_DIR/.bashrc > $HOME/.bashrc
echo "==========================================================="
echo "             import gitconfig                              "
echo "-----------------------------------------------------------"
cat $DOTFILES_DIR/.gitconfig >> $HOME/.gitconfig
echo "==========================================================="
echo "             import terraformrc                            "
echo "-----------------------------------------------------------"
cat $DOTFILES_DIR/.terraformrc >> $HOME/.terraformrc
echo "==========================================================="
echo "             import npmrc                                  "
echo "-----------------------------------------------------------"
mkdir $HOME/.node_modules
cat $DOTFILES_DIR/.npmrc >> $HOME/.npmrc

echo "==========================================================="
echo "             import .local scripts                         "
echo "-----------------------------------------------------------"
mkdir -p $HOME/.local/bin
cp -r -n $DOTFILES_DIR/.local $HOME/.local

echo "==========================================================="
echo "             install flyctl                                "
echo "-----------------------------------------------------------"
curl -L https://fly.io/install.sh | sh

echo "==========================================================="
echo "             install terraform                             "
echo "-----------------------------------------------------------"
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --yes --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform
mkdir -p $HOME/.cache/terraform

# make directly highlighting readable - needs to be after zshrc line
echo "" >> $HOME/.zshrc
echo "# remove ls and directory completion highlight color" >> $HOME/.zshrc
echo "_ls_colors=':ow=01;33'" >> $HOME/.zshrc
echo 'zstyle ":completion:*:default" list-colors "${(s.:.)_ls_colors}"' >> $HOME/.zshrc
echo 'LS_COLORS+=$_ls_colors' >> $HOME/.zshrc

sudo apt-get clean all
sudo apt -y autoremove

# open zsh and exit to run first start tasks
echo exit | script -qec zsh /dev/null >/dev/null
